/// Module: suibond
module suibond::suibond {
  use suibond::developer;
  use suibond::foundation;
  use suibond::platform;

  use std::string::{String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};

  // DEVELOPER
  entry fun mint_developer_cap(name: String,  ctx: &mut TxContext) {
    developer::mint_developer_cap(name, ctx);
  }

  //FOUNDATION
  entry fun mint_foundation_cap(name: String, ctx: &mut TxContext) {
    foundation::mint_foundation_cap(name, ctx);
  }


  // DEVELOPER
  entry fun create_project(ctx: &mut TxContext) {

  }

  // DEVELOPER
  entry fun add_milestone(ctx: &mut TxContext) {

  }

  // DEVELOPER
  entry fun propose_and_stake(ctx: &mut TxContext) {

  }


  //FOUNDATION
  entry fun confirm_proposal(ctx: &mut TxContext) {

  }


  // DEVELOPER
  entry fun submit_milestone(ctx: &mut TxContext) {

  }


  //FOUNDATION
  entry fun confirm_milestone(ctx: &mut TxContext) {

  }

  //FOUNDATION
  entry fun reject_milestone(ctx: &mut TxContext) {

  }

}

