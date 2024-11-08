
module suibond::developer_cap {
  use std::string::{String};

  public struct DeveloperCap has key, store {
    id: UID,
    owner: address,
    name: String,
    unsubmitted_proposal: vector<ID>,
    completed_proposal: vector<ID>,
  }

  // ================= METHODS =================

  // ================= FUNCTIONS =================

  public fun new(name: String, ctx: &mut TxContext): DeveloperCap {
    DeveloperCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      unsubmitted_proposal: vector<ID>[],
      completed_proposal: vector<ID>[],
    }
  }

  #[allow(lint(self_transfer))]
  public fun mint(name: String, ctx: &mut TxContext) {
    let dev_cap = new(name, ctx);
    transfer::public_transfer(dev_cap, ctx.sender())
  }
}