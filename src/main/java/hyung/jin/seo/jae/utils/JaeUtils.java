package hyung.jin.seo.jae.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;
import java.util.regex.Pattern;

import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;

import hyung.jin.seo.jae.model.TestAnswerItem;

public class JaeUtils {
	
	public static final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
	public static final SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy-MM-dd");
	private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
    private static final Pattern EMAIL_PATTERN = Pattern.compile(EMAIL_REGEX);

  
	
	// convert date format from yyyy-MM-dd to dd/MM/yyyy, for example 2023-04-22 to 22/04/2023
	public static String convertToddMMyyyyFormat(String date) throws ParseException {
		String formatted = "";
		if(StringUtils.isNotBlank(date)) {
			Date display = displayFormat.parse(date);
			formatted = dateFormat.format(display);
		}
		return formatted;
	}
	
	// convert date format from dd/MM/yyyy to yyyy-MM-dd, for example 22/04/2023 to 2023-04-22
	public static String convertToyyyyMMddFormat(String date) throws ParseException {
		String formatted = "";
		if(StringUtils.isNotBlank(date)) {
			Date display = dateFormat.parse(date);
			formatted = displayFormat.format(display);
		}
		return formatted;
	}
	
	// check if string date is formatted 'dd/MM/yyyy'
	public static boolean isValidDateFormat(String date) {
		dateFormat.setLenient(false);
		try {
			dateFormat.parse(date);
			return true;
		}catch(ParseException e) {
			return false;
		}
	}

	// return date as dd/MM/yyyy
	public static String getToday(){
		String pattern = "dd/MM/yyyy";
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
		String date = simpleDateFormat.format(new Date());
		return date;
	}

	// return date info for Student Memo
	public static String getTodayForMemo(String user){
		String pattern = "dd/MM/yyyy";
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
		String date = simpleDateFormat.format(new Date());
		return " [" + user + " at "+ date + "]";
	}
	
	// check wether Today is between from and to
    public static boolean checkIfTodayBelongTo(String from, String to) throws ParseException {
        Date fromDate = displayFormat.parse(from);
        Date toDate = displayFormat.parse(to);
		// Truncate the time component from today
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(new Date());
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
		Date today = calendar.getTime();
      	return (today.compareTo(fromDate) >= 0 && today.compareTo(toDate) <= 0); 
    }

	// check wether date is between from and to.
	// date format must be 'dd/MM/yyyy'
	public static boolean checkIfTodayBelongTo(String date, String from, String to) throws ParseException {
		Date fromDate = displayFormat.parse(from);
		Date toDate = displayFormat.parse(to);
		Date specificDate = dateFormat.parse(date);
		// Truncate the time component from today
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(specificDate);
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
		Date checkDate = calendar.getTime();
		return (checkDate.compareTo(fromDate) >= 0 && checkDate.compareTo(toDate) <= 0);
	}

	// check wether 1st date is earlier than 2nd date.
	public static boolean isEarlier(String date1String, String date2String) throws ParseException {
        Date date1 = dateFormat.parse(date1String);
        Date date2 = dateFormat.parse(date2String);
        int comparisonResult = date1.compareTo(date2);

        return (comparisonResult < 0);
    }

	// clear all info in session
	public static void clearSession(HttpSession session){
		Enumeration<String> names = session.getAttributeNames();
		while(names.hasMoreElements()){
			String name = names.nextElement();
			session.removeAttribute(name);
		}
	}

	// calculate score by comparing student answers and answer sheet
	public static double calculateScore(List<Integer> studentAnswers, List<Integer> answerSheet) {
        // Check if both lists have the same size
        if ((studentAnswers==null) || (answerSheet==null) || (studentAnswers.size() != answerSheet.size())) {
            return 0;
        }
        int totalQuestions = answerSheet.get(0); // Assuming the first element is the total count

        // Iterate through the lists and compare corresponding elements
        int correctAnswers = 0;
        for (int i = 1; i <= totalQuestions; i++) {
            int studentAnswer = studentAnswers.get(i);
            int correctAnswer = answerSheet.get(i);

            if (studentAnswer == correctAnswer) {
                correctAnswers++;
            }
        }
        // Calculate the final score as a percentage
        double score = ((double) correctAnswers / totalQuestions) * 100;
		double rounded = Math.round(score * 100.0) / 100.0;
        return rounded;
    }

	// return grade name
	public static String getGradeName(String value) {
		String gradeText = "";
		switch(value) {
			case "1": gradeText = "P2"; break;
			case "2": gradeText = "P3"; break;
			case "3": gradeText = "P4"; break;
			case "4": gradeText = "P5"; break;
			case "5": gradeText = "P6"; break;
			case "6": gradeText = "S7"; break;
			case "7": gradeText = "S8"; break;
			case "8": gradeText = "S9"; break;
			case "9": gradeText = "S10"; break;
			case "10": gradeText = "S10E"; break;
			case "11": gradeText = "TT6"; break;
			case "12": gradeText = "TT8"; break;
			case "13": gradeText = "TT8E"; break;
			case "14": gradeText = "SRW4"; break;
			case "15": gradeText = "SRW5"; break;
			case "16": gradeText = "SRW6"; break;
			case "17": gradeText = "SRW7"; break;
			case "18": gradeText = "SRW8"; break;
			case "19": gradeText = "JMSS"; break;
			case "20": gradeText = "VCE"; 
		}
		return gradeText;
	}

	// return grade year name
	public static String getGradeYearName(String value) {
		String gradeText = "";
		switch(value) {
			case "1": gradeText = "Year 2"; break;
			case "2": gradeText = "Year 3"; break;
			case "3": gradeText = "Year 4"; break;
			case "4": gradeText = "Year 5"; break;
			case "5": gradeText = "Year 6"; break;
			case "6": gradeText = "Year 7"; break;
			case "7": gradeText = "Year 8"; break;
			case "8": gradeText = "Year 9"; break;
			case "9": gradeText = "Year 10"; break;
			case "10": gradeText = "Year 1"; 
		}
		return gradeText;
	}

	// return grade name
	public static String getGradeCode(String value) {
		String gradeText = "";
		switch(value) {
			case "P2": gradeText = "1"; break;
			case "P3": gradeText = "2"; break;
			case "P4": gradeText = "3"; break;
			case "P5": gradeText = "4"; break;
			case "P6": gradeText = "5"; break;
			case "S7": gradeText = "6"; break;
			case "S8": gradeText = "7"; break;
			case "S9": gradeText = "8"; break;
			case "S10": gradeText = "9"; break;
			case "S10E": gradeText = "10"; break;
			case "TT6": gradeText = "11"; break;
			case "TT8": gradeText = "12"; break;
			case "TT8E": gradeText = "13"; break;
			case "SRW4": gradeText = "14"; break;
			case "SRW5": gradeText = "15"; break;
			case "SRW6": gradeText = "16"; break;
			case "SRW7": gradeText = "17"; break;
			case "SRW8": gradeText = "18"; break;
			case "JMSS": gradeText = "19"; break;
			case "VCE": gradeText = "20"; 
		}
		return gradeText;
	}

	// get year from date format
	public static int getYear(String date){
		int year = 0;
		String[] parts = date.split("/");
		if(parts.length > 0){
			year = Integer.parseInt(parts[2]);
		}
		return year;
	}

	// return difference between startDateTime and endDateTime
	public static long getDuration(LocalDateTime startDateTime, LocalDateTime endDateTime) throws ParseException {
		if (startDateTime != null && endDateTime != null) {
            Duration duration = Duration.between(startDateTime, endDateTime);
            return duration.toMinutes();
        } else {
            return 0; // or handle the null case as needed
        }
	}

	// validate email format
	public static boolean isValidEmail(String email) {
        if (email == null || email.isEmpty()) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email).matches();
    }

	// return String array by delimiting string with comma
	public static String[] splitString(String value) {
		String[] parts = value.split(",");
		return parts;
	}

	// return String by joining string array with comma
	public static String joinString(String[] values) {
		if(values == null || values.length == 0)
		{ 
			return "";
		}else if(values.length == 1) {
			return values[0];
		}else{
			String joined = String.join(",", values);
			return joined;
		}
	}

	// return test group name
	public static String getTestGroup(int value) {
		String answer = "";
		switch(value) {
			case 1: answer = "Mega Test"; break;
			case 2: answer = "Revision Test"; break;
			case 3: answer = "Edu Test"; break;
			case 4: answer = "Acer Test"; break;
			case 5: answer = "Mock Test"; break;
		}
		return answer;
	}

	// count test score by comparing student answers and answer sheet
	public static int countTestScore(List<Integer> studentAnswers, List<TestAnswerItem> answerSheet) {
		// Check if both lists have the same size
        if ((studentAnswers==null) || (answerSheet==null) || (studentAnswers.size() != answerSheet.size())) {
            return 0;
        }
        int totalQuestions = answerSheet.size();
        // Iterate through the lists and compare corresponding elements
        int correctAnswers = 0;
        for (int i = 0; i < totalQuestions; i++) {
            int studentAnswer = studentAnswers.get(i);
            int correctAnswer = answerSheet.get(i).getAnswer();

            if (studentAnswer == correctAnswer) {
                correctAnswers++;
            }
        }
        // Return the count of correct answers
        return correctAnswers;
	}

	// format answer
	public static String formatAnswer(int num){
		String answer = "";
		switch(num){
			case 1:
				answer = "A";
				break;
			case 2:
				answer = "B";
				break;
			case 3:
				answer = "C";
				break;
			case 4:
				answer = "D";
				break;
			case 5:
				answer = "E";
				break;
			default:
				answer = "";
		}
		return answer;
	}
}
