
module suibond::developer_cap {
  use std::string::{String};
  use sui::dynamic_object_field::{Self};
  use sui::coin::{Coin};
  use sui::sui::{SUI};
  use suibond::proposal::{Proposal};
  use suibond::platform::{SuibondPlatform};
  use suibond::foundation::{Foundation};
  use suibond::bounty::{Bounty};

  public struct DeveloperCap has key, store {
    id: UID,
    owner: address,
    name: String,
    unsubmitted_proposal: vector<ID>,
    submitted_proposal: vector<ID>,
    completed_proposal: vector<ID>,
  }

  // ================= METHODS =================

  public fun id(developer_cap: &DeveloperCap): ID {
    object::id(developer_cap)
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

  public fun submit_proposal(developer_cap: &mut DeveloperCap, platform: &mut SuibondPlatform, foundation: &Foundation, bounty: &Bounty, proposal: Proposal) {
    developer_cap.submitted_proposal.push_back(proposal.id());
    platform.add_proposal(foundation, bounty, proposal)
  }

  
  public fun propose_and_stake(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation: &Foundation,
    bounty: &Bounty,
    stake: Coin<SUI>,
    ctx: &mut TxContext
  ) {
    let mut proposal = developer_cap.remove_unsubmitted_proposal();
    proposal.stake(stake);
    proposal.set_project_state_submitted();
    developer_cap.submit_proposal(platform, foundation, bounty, proposal);


  }

  // ================= FUNCTIONS =================

  fun new(name: String, ctx: &mut TxContext): DeveloperCap {
    DeveloperCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      unsubmitted_proposal: vector<ID>[],
      submitted_proposal: vector<ID>[],
      completed_proposal: vector<ID>[],
    }
  }

  #[allow(lint(self_transfer))]
  public fun mint(name: String, ctx: &mut TxContext) {
    let dev_cap = new(name, ctx);
    transfer::public_transfer(dev_cap, ctx.sender())
  }
}