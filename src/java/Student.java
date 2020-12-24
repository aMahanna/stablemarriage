public class Student extends Person {

	private Employer[] prefList; // Stores the list of employer preferences in order for the Student instance
	private int iterator = 0; // Iterator used to update Student's preference list as students are added

	public Student(String name) {
		super(name);
		prefList = new Employer[10];

	}

	// Returns an Employer instance from the Student's preferenceList at the provided index
	public Employer getEmployer(int index) {
		if (index < 0 || index > 9) {
			throw new IndexOutOfBoundsException("index is incorrect");
		}
		return this.prefList[index]; 
	}

	// Returns the index of the employer instance provided (0 = student's first choice, 9 = student's last choice)
	public int findEmployerRank(Employer employer) {
		for (int i = 0; i < 10; i++) {
			if (prefList[i].getName().equals(employer.getName())) {
				return i;
			}
		}

		return -1; // Return -1 if employer not found
	}

	// Adds the provided employer to the preferenceList array - also increments iterator for the next time
	public void addEmployerToList(Employer someEmployer) {
		if (this.iterator == 10) {
			System.out.println("Maximum instertion reached");
			return;
		}

		this.prefList[iterator] = someEmployer;
		this.iterator += 1;
	}
}