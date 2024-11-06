/// Module: suibond
module suibond::suibond {
  use suibond::developer;
  use suibond::foundation;
  use suibond::platform;

  entry fun register_developer(ctx: &mut TxContext) {
    developer::register_developer(ctx);
  }

  entry fun register_foundation(ctx: &mut TxContext) {
    foundation::register_foundation(ctx);
  }

  entry fun propose_and_stake(ctx: &mut TxContext) {

  }

  entry fun confirm_proposal(ctx: &mut TxContext) {

  }

  entry fun submit_milestone(ctx: &mut TxContext) {

  }

  entry fun confirm_milestone(ctx: &mut TxContext) {

  }

  entry fun reject_milestone(ctx: &mut TxContext) {

  }

}

