module suibond::project {
  use std::string::{String};
  use suibond::milestone::{Self, Milestone};

  public struct Project has key, store {
    id: UID,
    proposal: ID,

    title: String,
    description: String,

    duration_epochs: u64,
    milestones: vector<Milestone>,
    current_processing_milestone_number: u64,
  }
  // ====================================================
  // ================= Create Functions =================
  public fun new(
    proposal_id: ID,
    title: String,
    description: String,
    ctx: &mut TxContext): Project {
      Project{
        id: object::new(ctx),
        proposal: proposal_id,
        title: title,
        description: description,
        duration_epochs: 0,
        milestones: vector<Milestone>[],
        current_processing_milestone_number: 0,
      }
  }
  
  // ===========================================================
  // ================= Entry Related Functions =================
  
	// ===========================================
  // ================= Methods =================

  // Read
  // ============
  public fun duration_epochs(project: &Project): u64 {
    project.duration_epochs
  }

  public fun current_processing_milestone_number(project: &Project): u64 {
    project.current_processing_milestone_number
  }

  public fun borrow_current_processing_milestone_mut(project: &mut Project): &mut Milestone {
    project.milestones.borrow_mut(project.current_processing_milestone_number)
  }
  
  // Borrow
  // ============

  // Check
  // ============
  public fun is_last_milestone(project: &mut Project): bool {
    project.current_processing_milestone_number == project.milestones.length()
  }

  // Set
  // ============
  public fun next_milestone(project: &mut Project) {
    project.current_processing_milestone_number = project.current_processing_milestone_number + 1;
  }

  // =============================================================
  // ================= Public-Mutative Functions =================
  public fun add_milestone(project: &mut Project, milestone: Milestone) {
      project.duration_epochs = project.duration_epochs + milestone.duration_epochs();
      project.milestones.push_back(milestone);
  }

  public fun create_and_add_milestone(
    project: &mut Project,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext) {
      let milestone_number = project.milestones.length();
      let milestone = milestone::new(
        milestone_number,
        title,
        description,
        duration_epochs,
        ctx
      );
      project.add_milestone(milestone);
  }

  public fun request_extend_deadline_of_milestone(project: &mut Project, ctx: &mut TxContext) {
    let milestone = project.milestones.borrow_mut(project.current_processing_milestone_number);
    assert!(!milestone.is_expired(ctx), 100);
    milestone.request_extend_deadline_of_milestone();
    project.duration_epochs = project.duration_epochs + milestone::CONST_EXTENDING_DURATION_EPOCHS();
  }

  // ==================================================
  // ================= TEST FUNCTIONS =================

}