
public class Match {
	private Student student;
	private Employer employer;

	public Match(Student student, Employer employer) { // Create a new match
		this.student = student;
		this.employer = employer;
		
		// Calls setMatch for each instance to inform that the instances have been matched
		this.student.setMatch(this); 
		this.employer.setMatch(this);
	}

	public Student getStudent() {
		return this.student;
	}
 
	public void replaceStudent(Student s) { 	// This replaces the student associated to this match instance
		this.student.setMatch(null); 			// It first informs the previous student that they no longer have a match
		this.student = s;						// Sets the new match to the student provided
		this.student.setMatch(this);			// Informas that new student now has a match
	}

	public void replaceEmployer(Employer e) { 	// This replaces the employer associated to this match instance
		this.employer.setMatch(null); 			// It first informs the previous employer that they no longer have a match
		this.employer = e; 						// Sets the new match to the employer provided
		this.employer.setMatch(this);			// Informas that new employer now has a match
	}

	public Employer getEmployer() {
		return this.employer;
	}

	public  void displayMatch() {
		System.out.println(this.student.getName() + " - " + this.employer.getName()); // Displays the name of the current instances matched
	}
}