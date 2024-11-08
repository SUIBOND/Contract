
module suibond::foundation_cap {
  use std::string::{String};

  public struct FoundationCap has key, store {
    id: UID,
    owner: address,
    name: String,
    foundation_ids: vector<ID>,
  }

  // ================= METHODS =================

  public fun id(foundation_cap: &FoundationCap): ID {
    object::id(foundation_cap)
  }

  public fun owner(foundation_cap: &FoundationCap): address {
    foundation_cap.owner
  }

  // ================= FUNCTIONS =================

  fun new(name: String, ctx: &mut TxContext): FoundationCap {
    FoundationCap{
      id: object::new(ctx),
      owner: ctx.sender(),
      name: name,
      foundation_ids: vector<ID>[],
    }
  }

  #[allow(lint(self_transfer))]
  public fun mint(name: String, ctx: &mut TxContext) {
    let platform = new(name, ctx);
    transfer::public_transfer(platform, ctx.sender())
  }


}