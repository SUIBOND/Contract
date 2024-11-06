module suibond::foundation {
  public struct Foundation has key, store {
    id: UID,
    owner: address
  }

  public struct Bounty has key, store {
    id: UID,
    foundation: address,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64
  }

}