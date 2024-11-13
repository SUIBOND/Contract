#[test_only]
module suibond::suibond_tests {
  // uncomment this line to import the module

  use sui::test_scenario;
  use sui::coin::{Self};
  use sui::sui::{Self,SUI};

  use suibond::suibond::{Self};
  use suibond::developer_cap::{Self, DeveloperCap};
  use suibond::proposal::{Self};
  use suibond::foundation_cap::{Self, FoundationCap};
  use suibond::foundation::{Self};
  use suibond::bounty::{Self};
  use suibond::platform::{Self, SuibondPlatform};

  use std::string::{Self, String};

  const ENotImplemented: u64 = 0;

  #[test_only]
  fun create_platform(ctx: &mut TxContext): SuibondPlatform {
    platform::new(ctx)
  } 


  #[test]
  fun test_suibond() {
      let mut ts = test_scenario::begin(@0xA);
      let ctx = test_scenario::ctx(&mut ts);
      let coin = coin::mint_for_testing<SUI>(50000, ctx);
      let mut stake = coin::mint_for_testing<SUI>(50000, ctx);
      

      let mut platform = create_platform(ctx);
      let mut developer_cap = developer_cap::new(string::utf8(b"dfsdf"), string::utf8(b"sdfsdf"), ctx);
      let mut foundation_cap = foundation_cap::new(string::utf8(b"dsdf"), ctx);

      // suibond::create_and_register_foundation(&mut foundation_cap, string::utf8(b"foundation1"), &mut platform, ctx);
      let foundation = foundation::new(foundation_cap.id(), string::utf8(b"foundation_name"), ctx);
      let foundation_id = foundation.id();
      foundation_cap.register_foundation(&mut platform, foundation);

      // entry public fun create_and_add_bounty_to_foundation(
      let bounty = bounty::new( foundation_id, string::utf8(b"bounty_name"), 1, 1, 0, 1000000, coin, ctx);
      let bounty_id = bounty.id();
      platform.add_bounty(foundation_id, bounty);

      // entry public fun create_proposal(
      let proposal = proposal::new( developer_cap.id(), foundation_id, bounty_id, string::utf8(b"proposal_title"), string::utf8(b"project_title"), string::utf8(b"project_description"), 100000, ctx);
      let proposal_id = proposal.id();
      developer_cap.add_unsubmitted_proposal(proposal);
      
      // entry public fun add_milestone_to_project(
      developer_cap.create_and_add_milestone(proposal_id, string::utf8(b"title"), string::utf8(b"descriptio"), 3, ctx);

      // entry public fun propose_and_stake(
      developer_cap.propose_and_stake(&mut platform, foundation_id, bounty_id, proposal_id, &mut stake, ctx);
      
      platform.delete();
      developer_cap.delete();
      foundation_cap.delete();
      transfer::public_transfer(stake, ctx.sender());

      test_scenario::end(ts);
      // pass
  }

  #[test, expected_failure(abort_code = ::suibond::suibond_tests::ENotImplemented)]
  fun test_suibond_fail() {
      abort ENotImplemented
  }

}