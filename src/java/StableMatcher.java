

import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;


public class StableMatcher {

	private Map<String, Student> studentMap;
	private Map<String, Employer> employerMap;
	private String[] employerKeys;
	private ArrayList<Match> matchesList;
	
	
	public static void main(String[] args) {

		StableMatcher a = new StableMatcher();

		a.createMaps("list_employers.csv", "list_students.csv");

		//a.displayPreferences();

		a.matchesList = a.galeShapleyAlgorithm();

		a.saveRecord(a.matchesList);

		for (Match m : a.matchesList) {
			m.displayMatch();
		}
				
	}

	public StableMatcher() {

		this.studentMap = new LinkedHashMap<String, Student>();
		this.employerMap = new LinkedHashMap<String, Employer>();
		this.employerKeys = new String[10];
	
	}

	/*
		This function is in charge of creating the Employer and Student maps.
		It will also make sure each Student instance and Employer instance will have a completed preference list

	*/
	private void createMaps(String firstFile, String secondFile) {
		Path employerPath = Paths.get(firstFile);
		Path studentPath = Paths.get(secondFile);

		
		String[] employerValues;
		String[] studentValues;

		
        try (BufferedReader employerBR = Files.newBufferedReader(employerPath,
            StandardCharsets.US_ASCII)) {

        	BufferedReader studentBR = Files.newBufferedReader(studentPath,
            StandardCharsets.US_ASCII);


            // read the first line from the employer text file
            String employerLine = employerBR.readLine();
            // read the first line from the student text file
            String studentLine = studentBR.readLine();


			int j = 0;
            // loop until all lines are read
            while (employerLine != null && studentLine != null) {

            	employerValues = employerLine.split(",");
            	studentValues = studentLine.split(",");


            	// Establish a map that associates the name of an employer (key) with an Employer instance (value)
            	// Establish a map that associates the name of a student (key) with a Student instance (value)
            	this.employerMap.put(employerValues[0], new Employer(employerValues[0])); 
            	this.studentMap.put(studentValues[0], new Student(studentValues[0]));



            	this.employerKeys[j] = employerValues[0]; // Store the names of all the employers in a array (this will be referenced later on in the algorithm)
            	j++; 

            	// Skip to next lines
                employerLine = employerBR.readLine();
                studentLine = studentBR.readLine();
               
            }


        } catch (IOException ioe) {
            ioe.printStackTrace();
        }

        try (BufferedReader employerBR = Files.newBufferedReader(employerPath,
            StandardCharsets.US_ASCII)) {

        	BufferedReader studentBR = Files.newBufferedReader(studentPath,
            StandardCharsets.US_ASCII);


        	int i;

            // read the first line from the employer text file
            String employerLine = employerBR.readLine();
            
            // read the first line from the student text file
            String studentLine = studentBR.readLine();

            // loop until all lines are read
            while (employerLine != null && studentLine != null) {

            	// Store values sperated by commas into arrays (employer, student1, student2, student3...) and (student, employer1, employer2, employer3...)
            	employerValues = employerLine.split(","); 
            	studentValues = studentLine.split(",");


            	/* 

					The following is meant to update the preference list of each Employer and Student instance so that
					we can properly reference them in the algorithm.
            	*/

            	Employer currentEmployer = this.employerMap.get(employerValues[0]); // Fetch the instance of Employer that we are currently looking at 
            
            	for (i = 1; i < 11; i++) { // Iterate through Student instances
            		Student iStudent = this.studentMap.get(employerValues[i]); // Fetch the instance of Student to add to the currentEmployer's preference list 
            		currentEmployer.addStudentToList(iStudent); // Add iStudent to the preference list of the currentEmployer Instance
            		this.employerMap.replace(employerValues[0], currentEmployer); // Update the instance of currentEmployer back into the map (this might not be necessary)
            	}

            	Student currentStudent = this.studentMap.get(studentValues[0]); // Fetch the instance of Student that we are currently looking at
            
            	for (i = 1; i < 11; i++) { // Iterate through Employer instances
            		Employer iEmployer = this.employerMap.get(studentValues[i]); // Fetch the instance of Employer to add to the currentStudent's preference list
            		currentStudent.addEmployerToList(iEmployer); // Add iEmployer to the preference list of the currentEmployer Instance
            		this.studentMap.replace(studentValues[0], currentStudent); // Update the instance of currentStudent back into the map (this might not be necessary)
            	}

            	// Skip to next lines
                employerLine = employerBR.readLine(); 
                studentLine = studentBR.readLine();
               
            }


        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
        
	}

	/*
		Function for testing purposes.
		Lists the preferences of each Student instance as well as the preferences of each Employer instance 
		This data is identical to the data found in the two CSV files provided for this assignment.
	*/
	private void displayPreferences() {
		System.out.println();
		System.out.println("STUDENT LIST");
		for (Map.Entry<String, Student> entry : studentMap.entrySet()) {
        	System.out.print(entry.getKey() + ": ");
        	for (int x = 0; x < 10; x++) {
        		System.out.print(entry.getValue().getEmployer(x).getName());;
        		System.out.print(", ");
        	}
        	System.out.println();
        }

        System.out.println();
        System.out.println("EMPLOYER LIST");

        for (Map.Entry<String, Employer> entry : employerMap.entrySet()) {
        	System.out.print(entry.getKey() + ": ");
        	for (int x = 0; x < 10; x++) {
        		System.out.print(entry.getValue().getStudent(x).getName());;
        		System.out.print(", ");
        	}
        	System.out.println();
        }

        System.out.println();
        System.out.println();
	}

	/*
		This function performs the stable matching
	*/
	private ArrayList<Match> galeShapleyAlgorithm() {

		ArrayList<Match> m = new ArrayList<Match>(); // Temporary arraylist to store the matches

		for (Employer currentEmployer : employerMap.values()) { // Iterate through each Employer
			int i = 0;
			while (!currentEmployer.isMatched()) { // While currentEmployer is not matched 
				
				Student targetStudent = currentEmployer.getStudent(i); // Select the iTH student choice of the employer (0,1,2,3,4...9)

				if (!targetStudent.isMatched()) { // If target student has not been matched, then create a new match with this employer
					m.add(new Match(targetStudent, currentEmployer));
					break; 												// Break the while loop, currentEmployer has been matched

				} else { // targetStudent is already matched

					// This boolean stores whether the student preferes the currentEmployer over the employer he has been previously matched with  
					boolean studentPrefersCurrentEmployer = targetStudent.findEmployerRank(currentEmployer) < targetStudent.findEmployerRank(targetStudent.getMatch().getEmployer());

					if (studentPrefersCurrentEmployer) {
						Employer tempEmployer = targetStudent.getMatch().getEmployer(); // Store the previously matched employer in a temp instance
						targetStudent.getMatch().replaceEmployer(currentEmployer); // Update targetStudent's new matched employer with currentEmployer
						currentEmployer = tempEmployer; // Update currentEmployer so that we can start looking for another match for the employer that just lost their student
						i = 0; // Reset i to have a fresh start in the new currentEmployer's preference list (avoids bugs)

					} else {
						i++; // targetStudent does NOT want currentEmployer, move on to the next student in the currentEmployer's preference list
					}
				}

			}

		}

		return m; // Matching is finished, return the list

	}

	/*
		Stores the matchesList results into an outputted CSV file
	*/
	private void saveRecord(ArrayList<Match> matchesList) {

		try {
			FileWriter fw = new FileWriter("matches_java.csv", false);
			BufferedWriter bw = new BufferedWriter(fw);
			PrintWriter pw = new PrintWriter(bw);

			for (Match m : matchesList) {
				pw.println(m.getStudent().getName() + " - " + m.getEmployer().getName() );
				pw.flush();
			}

			pw.close();


		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}



}