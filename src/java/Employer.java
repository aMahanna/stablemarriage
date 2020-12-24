
public class Employer extends Person {

	private Student[] prefList; // Stores the list of student preferences in order for the Employer instance
	private int iterator = 0; // Iterator used to update Employer's preference list as students are added

	public Employer(String name) {
		super(name);
		prefList = new Student[10];
	}

	// Returns a Student instance from the Employer's preferenceList at the provided index
	public Student getStudent(int index) {
		if (index < 0 || index > 9) {
			throw new IndexOutOfBoundsException("index is incorrect");
		}
		return this.prefList[index]; 
	}

	// Adds the provided student to the preferenceList array - also increments iterator for the next time
	public void addStudentToList(Student someStudent) {
		if (this.iterator == 10) {
			System.out.println("Maximum instertion reached");
			return;
		}
		this.prefList[iterator] = someStudent;
		this.iterator += 1;
	}

}