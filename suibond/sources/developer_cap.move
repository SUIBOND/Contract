
module suibond::developer_cap {
  use std::string::{String};
  use sui::dynamic_object_field::{Self};
  use sui::coin::{Coin};
  use sui::sui::{SUI};
  use suibond::proposal::{Proposal};
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

  // ================= METHODS =================

  public fun id(developer_cap: &DeveloperCap): ID {
    object::id(developer_cap)
  }

  public fun borrow_proposal_mut(developer_cap: &mut DeveloperCap, proposal_id: ID): &mut Proposal {
    dynamic_object_field::borrow_mut(&mut developer_cap.id, proposal_id)
  }

  public fun check_if_developer_is_proposer(developer_cap: &mut DeveloperCap, proposal: &Proposal, ctx: &mut TxContext) {
    assert!(developer_cap.owner == ctx.sender(), 100);
    assert!(developer_cap.owner == proposal.proposer(), 100);
  }


  public fun create_and_add_milestone(
    developer_cap: &mut DeveloperCap, 
    proposal_id: ID,
    // milestone_number: u64,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
    let proposal = developer_cap.borrow_proposal_mut(proposal_id);
    proposal.create_and_add_milestone(title, description, duration_epochs, ctx);
  }

  public fun add_unsubmitted_proposal(developer_cap: &mut DeveloperCap, proposal: Proposal) {
    assert!(developer_cap.unsubmitted_proposal.length() <= 1, 100); // for version 1 (easy version)

    developer_cap.unsubmitted_proposal.push_back(proposal.id());
    dynamic_object_field::add(&mut developer_cap.id, proposal.id(), proposal);
  }

  public fun remove_unsubmitted_proposal(developer_cap: &mut DeveloperCap): Proposal {
    // easy version 
    let proposal_id = developer_cap.unsubmitted_proposal.pop_back();
    dynamic_object_field::remove(&mut developer_cap.id, proposal_id)
  }

  public fun add_rejected_or_expired_proposal(developer_cap: &mut DeveloperCap, proposal: Proposal) {
    developer_cap.rejected_or_expired_proposal.push_back(proposal.id());
    dynamic_object_field::add(&mut developer_cap.id, proposal.id(), proposal);
  }

  public fun submit_proposal(developer_cap: &mut DeveloperCap, platform: &mut SuibondPlatform, foundation_id: ID, bounty_id: ID, proposal: Proposal, ctx: &mut TxContext) {
    developer_cap.submitted_proposal.push_back(proposal.id());
    let mut proposal = proposal;
    proposal.set_state_submitted();
    proposal.set_submitted_epochs(ctx);
    platform.add_proposal(foundation_id, bounty_id, proposal);
  }

  public fun propose_and_stake(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    stake: &mut Coin<SUI>,
    ctx: &mut TxContext
  ) {
    let mut proposal = developer_cap.remove_unsubmitted_proposal();
    let stake_amount_mist = platform.get_stake_amount(foundation_id, bounty_id, proposal_id);
    let stake = stake.split(stake_amount_mist, ctx);
    proposal.stake(stake);
    developer_cap.submit_proposal(platform, foundation_id, bounty_id, proposal, ctx);
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

  public fun submit_milestone(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    milestone_submission_id: ID,
    ctx: &mut TxContext) {
      let proposal = platform.borrow_processing_proposal(foundation_id, bounty_id, proposal_id);
      developer_cap.check_if_developer_is_proposer(proposal, ctx);
      proposal.submit_milestone(milestone_submission_id, ctx);
  }

  public fun request_extend_deadline_of_milestone(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      let proposal = platform.borrow_processing_proposal(foundation_id, bounty_id, proposal_id);
      developer_cap.check_if_developer_is_proposer(proposal, ctx);
      proposal.request_extend_deadline_of_milestone(ctx);
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

  // ================= FUNCTIONS =================

  fun new(name: String, url: String, ctx: &mut TxContext): DeveloperCap {
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

  #[allow(lint(self_transfer))]
  public fun mint(name: String, url: String, ctx: &mut TxContext) {
    let dev_cap = new(name, url, ctx);
    transfer::public_transfer(dev_cap, ctx.sender())
  }
}