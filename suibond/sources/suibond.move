/// Module: suibond
module suibond::suibond {
  use suibond::developer;
  use suibond::foundation;
  use suibond::platform;

  use std::string::{String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};

  // -----------------------------------------
  // STEP 0 : Identify
  // DEVELOPER
  entry fun mint_developer_cap(name: String,  ctx: &mut TxContext) {
    developer::mint_developer_cap(name, ctx);
  }

  //FOUNDATION
  entry fun mint_foundation_cap(name: String, ctx: &mut TxContext) {
    foundation::mint_foundation_cap(name, ctx);
  }


  // -----------------------------------------
  // STEP 1 : Create and Register Foundation
  //FOUNDATION
  entry fun create_foundation(foundation_cap: ID, name: String, ctx: &mut TxContext) {
    let foundation = foundation::new_foundation(foundation_cap, name, ctx);
    transfer::public_transfer(foundation, ctx.sender());
  }

  // //FOUNDATION
  // entry fun update_bounty(ctx: &mut TxContext) {

  // }

  //FOUNDATION
  entry fun register_foundation(ctx: &mut TxContext) {

  }

  //FOUNDATION
  entry fun add_bounty_to_foundation(ctx: &mut TxContext) {

  }


  // -----------------------------------------
  // STEP 2-1 : Create Project
  // DEVELOPER
  entry fun create_project_and_proposal(ctx: &mut TxContext) {

  }

  // DEVELOPER
  entry fun add_milestone_to_project(ctx: &mut TxContext) {

  }

  // // DEVELOPER
  // entry fun update_milestone(ctx: &mut TxContext) {

  // }

  // STEP 2-2 : Propose Project
  // DEVELOPER
  entry fun propose_and_stake(ctx: &mut TxContext) {

  }


  // -----------------------------------------
  // STEP 3 : Confirm Proposal
  //FOUNDATION
  entry fun confirm_proposal(ctx: &mut TxContext) {

  }

  //FOUNDATION
  entry fun reject_proposal(ctx: &mut TxContext) {

  }

  // automatically rejected


  // -----------------------------------------
  // STEP 4-1 : Process Milestone or Get Back Stake Amount For Unconfirmed Proposal
  // DEVELOPER
  entry fun unstake_unconfirmed_proposal(ctx: &mut TxContext) {

  }

  // DEVELOPER
  entry fun submit_milestone(ctx: &mut TxContext) {

  }

  // DEVELOPER
  entry fun request_extend_deadline_of_milestone(ctx: &mut TxContext) {

  }

  // STEP 4-2 : Confirm Milestone And Get Grant For The Milestone
  //FOUNDATION
  entry fun confirm_milestone(ctx: &mut TxContext) {

    // if the milestone deadline is missed, developer will get slashing

    // if the milestone is last one, developer will get stake amount
  }

  //FOUNDATION
  entry fun reject_milestone(ctx: &mut TxContext) {

  }

}

