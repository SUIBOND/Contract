/// Module: suibond
module suibond::suibond {
  use suibond::developer;
  use suibond::developer_cap;
  use suibond::foundation::{Self, Foundation};
  use suibond::foundation_cap::{Self, FoundationCap};
  use suibond::platform::{Self, SuibondPlatform};

  use std::string::{String};
  use sui::coin::{Self, Coin};
  use sui::sui::{Self, SUI};


  fun init(ctx: &mut TxContext) {
    platform::create_and_share(ctx);
  }


  // -----------------------------------------
  // STEP 0 : Identify
  // DEVELOPER
  entry fun mint_developer_cap(name: String,  ctx: &mut TxContext) {
    developer_cap::mint(name, ctx);
  }

  //FOUNDATION
  entry fun mint_foundation_cap(name: String, ctx: &mut TxContext) {
    foundation_cap::mint(name, ctx);
  }


  // -----------------------------------------
  // STEP 1 : Create and Register Foundation
  //FOUNDATION
  entry fun create_foundation(foundation_cap: &FoundationCap, name: String, ctx: &mut TxContext) {
    let foundation = foundation::new(foundation_cap.id(), name, ctx);
    transfer::public_transfer(foundation, ctx.sender());
  }

  //FOUNDATION
  entry fun add_bounty_to_foundation(
    foundation: &mut Foundation, 
    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,
    coin: Coin<SUI>,
    ctx: &mut TxContext) {
      foundation.add_bounty_to_foundation(name, bounty_type, risk_percent, min_amount, max_amount, coin, ctx);
  }

  //FOUNDATION
  entry fun register_foundation(platform: &mut SuibondPlatform, foundation_cap: &mut FoundationCap, foundation: Foundation, ctx: &mut TxContext) {
    assert!(foundation_cap.owner() == ctx.sender(),100);
    assert!(foundation.owner() == ctx.sender(),101);
    assert!(foundation.cap() == foundation_cap.id(), 102);

    foundation_cap.add_foundation(&foundation);
    platform.register_foundation(foundation);
  }

  //FOUNDATION
  entry fun add_bounty_to_foundation_in_platform(
    platform: &mut SuibondPlatform, 
    foundation: &Foundation, 
    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,
    coin: Coin<SUI>,
    ctx: &mut TxContext) {
      platform.add_bounty_to_foundation_in_platform(foundation, name, bounty_type, risk_percent, min_amount, max_amount, coin, ctx);
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

