module suibond::developer {
  public struct Developer has key, store {
    id: UID,
    owner: address
  }

  public struct Proposal has key, store {
    id: UID,
    proposer: address,
    project: Project,
    milestones: vector<Milestone>,
    milestone_number: u64
  }

  public struct Project has key, store {
    id: UID,
  }

  public struct Milestone has key, store {
    id: UID
  }
}