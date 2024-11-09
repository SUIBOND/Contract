
module suibond::developer_cap {
  use std::string::{String};
  use sui::dynamic_object_field::{Self};
  use suibond::proposal::{Proposal};

  public struct DeveloperCap has key, store {
    id: UID,
    owner: address,
    name: String,
    unsubmitted_proposal: vector<ID>,
    processing_proposal: vector<ID>,
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

  // ================= FUNCTIONS =================

  fun new(name: String, ctx: &mut TxContext): DeveloperCap {
    DeveloperCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      unsubmitted_proposal: vector<ID>[],
      processing_proposal: vector<ID>[],
      completed_proposal: vector<ID>[],
    }
  }

  #[allow(lint(self_transfer))]
  public fun mint(name: String, ctx: &mut TxContext) {
    let dev_cap = new(name, ctx);
    transfer::public_transfer(dev_cap, ctx.sender())
  }
}