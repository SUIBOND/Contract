
module suibond::developer_cap {
  use std::string::{String};
  use std::u64::{Self};
  use sui::dynamic_object_field::{Self};
  use sui::coin::{Coin};
  use sui::sui::{SUI};
  use suibond::proposal::{Self, Proposal};
  use suibond::platform::{SuibondPlatform};

  public struct DeveloperCap has key, store {
    id: UID,
    owner: address,
    name: String,
    url: String,
    unsubmitted_proposal: vector<ID>,
    submitted_proposal: vector<ID>,
    rejected_or_expired_proposal: vector<ID>,
    completed_proposal: vector<ID>,
  }

  // ====================================================
  // ================= Create Functions =================
  public fun new(name: String, url: String, ctx: &mut TxContext): DeveloperCap {
    DeveloperCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      url: url,
      unsubmitted_proposal: vector<ID>[],
      submitted_proposal: vector<ID>[],
      rejected_or_expired_proposal: vector<ID>[],
      completed_proposal: vector<ID>[],
    }
  }

  // ===========================================================
  // ================= Entry Related Functions =================
  #[allow(lint(self_transfer))]
  public fun mint(name: String, url: String, ctx: &mut TxContext) {
    let dev_cap = new(name, url, ctx);
    transfer::public_transfer(dev_cap, ctx.sender())
  }

  public fun update_developer_info(
    developer_cap: &mut DeveloperCap,
    name: String,
    url: String,
    ctx: &mut TxContext) {
      assert!(developer_cap.owner == ctx.sender(), 100);
      developer_cap.name = name;
      developer_cap.url = url;
  }

  public fun create_proposal(
    developer_cap: &mut DeveloperCap,
    foundation_id: ID, 
    bounty_id: ID, 
    proposal_title: String, 
    project_title: String,
    project_description: String,
    grant_size: u64,
    ctx: &mut TxContext) {
      let proposal = proposal::new( developer_cap.id(), foundation_id, bounty_id, proposal_title, project_title, project_description, grant_size, ctx);
      developer_cap.add_unsubmitted_proposal(proposal);
  }

  public fun create_and_add_milestone(
    developer_cap: &mut DeveloperCap, 
    proposal_id: ID,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
      let proposal = developer_cap.borrow_proposal_mut(proposal_id);
      proposal.create_and_add_milestone(title, description, duration_epochs, ctx);
  }

  public fun stake_and_propose(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    stake: &mut Coin<SUI>,
    ctx: &mut TxContext
  ) {
    let mut proposal = developer_cap.remove_unsubmitted_proposal(proposal_id);

    let risk_percent = platform.risk_percent(foundation_id, bounty_id);
    let stake_amount_mist = u64::divide_and_round_up(proposal.grant_size() * risk_percent, 100);
    let stake = stake.split(stake_amount_mist, ctx);

    proposal.stake(stake);
    proposal.set_state_submitted();
    proposal.set_submitted_and_deadline_epochs(ctx);
    developer_cap.submitted_proposal.push_back(proposal.id());

    platform.add_proposal(foundation_id, bounty_id, proposal);
  }

  public fun unstake_rejected_or_expired_proposal(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      developer_cap.bring_back_rejected_or_expired_proposal(platform, foundation_id, bounty_id, proposal_id, ctx);
      developer_cap.unstake_from_proposal(proposal_id, ctx);
    }

  // ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun id(developer_cap: &DeveloperCap): ID {
    object::id(developer_cap)
  }

  public fun owner(developer_cap: &DeveloperCap): address {
    developer_cap.owner
  }

  // Borrow
  // ============
  public fun borrow_proposal_mut(developer_cap: &mut DeveloperCap, proposal_id: ID): &mut Proposal {
    dynamic_object_field::borrow_mut(&mut developer_cap.id, proposal_id)
  }

  // Check
  // ============
  public fun check_owner(developer_cap: &DeveloperCap, ctx: &mut TxContext){
    assert!(developer_cap.owner() == ctx.sender(), 100)
  }

  public fun check_if_developer_is_proposer(developer_cap: &mut DeveloperCap, proposal: &Proposal, ctx: &mut TxContext) {
    assert!(developer_cap.owner == ctx.sender(), 100);
    assert!(developer_cap.owner == proposal.proposer(), 100);
  }

  // =============================================================
  // ================= Public-Mutative Functions =================

  // Proposal
  // ============
  public fun add_unsubmitted_proposal(developer_cap: &mut DeveloperCap, proposal: Proposal) {
    developer_cap.unsubmitted_proposal.push_back(proposal.id());
    dynamic_object_field::add(&mut developer_cap.id, proposal.id(), proposal);
  }

  public fun remove_unsubmitted_proposal(developer_cap: &mut DeveloperCap, proposal_id: ID): Proposal {
    let (is_contain, index) = developer_cap.unsubmitted_proposal.index_of(&proposal_id);
    if (is_contain) {
      developer_cap.unsubmitted_proposal.remove(index);
    };
    dynamic_object_field::remove(&mut developer_cap.id, proposal_id)
  }

  public fun add_rejected_or_expired_proposal(developer_cap: &mut DeveloperCap, proposal: Proposal) {
    developer_cap.rejected_or_expired_proposal.push_back(proposal.id());
    dynamic_object_field::add(&mut developer_cap.id, proposal.id(), proposal);
  }

  public fun bring_back_rejected_or_expired_proposal(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      let proposal = platform.remove_rejected_or_expired_proposal(foundation_id, bounty_id, proposal_id, ctx);
      developer_cap.add_rejected_or_expired_proposal(proposal);
  }

  public fun unstake_from_proposal(
    developer_cap: &mut DeveloperCap,
    proposal_id: ID,
    ctx: &mut TxContext) {
      let proposal = developer_cap.borrow_proposal_mut(proposal_id);
      proposal.unstake(ctx);
  }

  // Milestone
  // ============
  public fun submit_milestone(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    milestone_submission_id: ID,
    ctx: &mut TxContext) {
      let proposal = platform.borrow_processing_proposal_mut(foundation_id, bounty_id, proposal_id);
      developer_cap.check_if_developer_is_proposer(proposal, ctx);

      assert!(proposal.is_processing(), 100);
      proposal.submit_milestone(milestone_submission_id, ctx);
  }

  public fun request_extend_deadline_of_milestone(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      let proposal = platform.borrow_processing_proposal_mut(foundation_id, bounty_id, proposal_id);
      developer_cap.check_if_developer_is_proposer(proposal, ctx);
      proposal.request_extend_deadline_of_milestone(ctx);
  }

  // ==================================================
  // ================= TEST FUNCTIONS =================

  #[test_only]
  public fun delete(developer_cap: DeveloperCap) {
    let DeveloperCap {
      id:id,
      owner:_,
      name:_,
      url:_,
      unsubmitted_proposal:_,
      submitted_proposal: _,
      rejected_or_expired_proposal: _,
      completed_proposal: _
    } = developer_cap;
    object::delete(id);
  }
}