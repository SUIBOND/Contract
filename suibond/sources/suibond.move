/// Module: suibond
module suibond::suibond {
  use suibond::developer_cap::{Self, DeveloperCap};
  use suibond::proposal::{Self};
  use suibond::foundation_cap::{Self, FoundationCap};
  use suibond::foundation::{Self};
  use suibond::platform::{Self, SuibondPlatform};

  use std::string::{String};
  use sui::coin::{Coin};
  use sui::sui::{SUI};

  fun init(ctx: &mut TxContext) {
    platform::create_and_share(ctx);
  }

  // -----------------------------------------
  // STEP 0 : Identify
  // DEVELOPER
  entry fun mint_developer_cap(name: String, url: String,  ctx: &mut TxContext) {
    developer_cap::mint(name, url, ctx);
  }

  // DEVELOPER
  entry fun update_developer_info(developer_cap: &mut DeveloperCap, name: String, url: String, ctx: &mut TxContext) {
    developer_cap.update_developer_info(name, url, ctx);
  }

  //FOUNDATION
  entry fun mint_foundation_cap(name: String, ctx: &mut TxContext) {
    foundation_cap::mint(name, ctx);
  }


  // -----------------------------------------
  // STEP 1 : Create and Register Foundation
  //FOUNDATION
  entry public fun create_and_register_foundation(foundation_cap: &mut FoundationCap, name: String, platform: &mut SuibondPlatform, ctx: &mut TxContext) {
    let foundation = foundation::new(foundation_cap.id(), name, ctx);
    foundation_cap.register_foundation(platform, foundation);
  }

  //FOUNDATION
  entry public fun create_and_add_bounty_to_foundation(
    foundation_cap: &FoundationCap,
    platform: &mut SuibondPlatform, 
    foundation_id: ID, 
    name: String,
    bounty_type: u64,
    risk_percent: u64,
    min_amount: u64,
    max_amount: u64,
    coin: Coin<SUI>,
    ctx: &mut TxContext) {
      foundation_cap.check_owner(ctx);
      platform.create_and_add_bounty(foundation_cap.id(), foundation_id, name, bounty_type, risk_percent, min_amount, max_amount, coin, ctx);
  }

  //FOUNDATION
  entry public fun add_fund_to_bounty(
    foundation_cap: &FoundationCap,
    platform: &mut SuibondPlatform, 
    foundation_id: ID, 
    bounty_id: ID, 
    coin: Coin<SUI>,
    ctx: &mut TxContext) {
      foundation_cap.check_owner(ctx);
      platform.add_fund_to_bounty(foundation_cap.id(), foundation_id, bounty_id, coin, ctx);
  }

  // -----------------------------------------
  // STEP 2-1 : Create Proposal with Project
  // DEVELOPER
  entry public fun create_proposal(
    developer_cap: &mut DeveloperCap, 
    foundation_id: ID, 
    bounty_id: ID, 
    proposal_title: String, 
    project_title: String,
    project_description: String,
    grant_size: u64,
    ctx: &mut TxContext) {
      developer_cap.check_owner(ctx);
      developer_cap.create_proposal(foundation_id, bounty_id, proposal_title, project_title, project_description, grant_size, ctx);
  }

  // DEVELOPER
  entry public fun add_milestone_to_project(
    developer_cap: &mut DeveloperCap, 
    proposal_id: ID,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
      developer_cap.check_owner(ctx);
      developer_cap.create_and_add_milestone(proposal_id, title, description, duration_epochs, ctx);
  }

  // // DEVELOPER
  // entry fun update_milestone(ctx: &mut TxContext) {

  // }

  // STEP 2-2 : Propose Project
  // DEVELOPER
  entry public fun stake_and_propose(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    stake: &mut Coin<SUI>,
    ctx: &mut TxContext
    ) {
      developer_cap.check_owner(ctx);
      developer_cap.stake_and_propose(platform, foundation_id, bounty_id, proposal_id, stake, ctx);
  }


  // -----------------------------------------
  // STEP 3 : Confirm Proposal
  //FOUNDATION
  entry public fun confirm_proposal(
    foundation_cap: &FoundationCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      foundation_cap.check_owner(ctx);
      foundation_cap.confirm_proposal(platform, foundation_id, bounty_id, proposal_id, ctx);
  }

  //FOUNDATION
  entry public fun reject_proposal(
    foundation_cap: &FoundationCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      foundation_cap.check_owner(ctx);
      foundation_cap.reject_proposal(platform, foundation_id, bounty_id, proposal_id, ctx);
  }

  // automatically rejected


  // -----------------------------------------
  // STEP 4-1 : Process Milestone or Get Back Stake Amount For Unconfirmed Proposal
  // DEVELOPER
  entry public fun unstake_rejected_or_expired_proposal(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      developer_cap.check_owner(ctx);
      developer_cap.unstake_rejected_or_expired_proposal(platform, foundation_id, bounty_id, proposal_id, ctx);
  }

  // DEVELOPER
  entry public fun submit_milestone(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    milestone_submission_id: ID,
    ctx: &mut TxContext) {
      developer_cap.check_owner(ctx);
      developer_cap.submit_milestone(platform, foundation_id, bounty_id, proposal_id, milestone_submission_id, ctx);
  }

  // DEVELOPER
  entry public fun request_extend_deadline_of_milestone(
    developer_cap: &mut DeveloperCap,
    platform: &mut SuibondPlatform,
    foundation_id: ID,
    bounty_id: ID,
    proposal_id: ID,
    ctx: &mut TxContext) {
      developer_cap.check_owner(ctx);
      developer_cap.request_extend_deadline_of_milestone(platform, foundation_id, bounty_id, proposal_id, ctx);
  }

  // STEP 4-2 : Confirm Milestone And Get Grant For The Milestone
  //FOUNDATION
  entry public fun confirm_milestone(ctx: &mut TxContext) {

    // if the milestone deadline is missed, developer will get slashing

    // if the milestone is last one, developer will get stake amount
  }

  //FOUNDATION
  entry public fun reject_milestone(ctx: &mut TxContext) {

  }

}

