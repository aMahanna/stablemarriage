
public class Person {
	private String name; 
	private Match match; // References to the match instance that the Person is in (null if not matched)

	public Person(String name) {
		if (name == null) {
			throw new IllegalArgumentException("name is null"); 
		}

		this.name = name;
	}

	public String getName() {
		return this.name;
	}

	// Checks if the person has been matched
	public boolean isMatched() {
		return this.match != null;
	}

	// Assigns a match to the person
	public void setMatch(Match m) {
		this.match = m;
	}

	public Match getMatch() {
		return this.match; // Returns the match instance 
	}

}