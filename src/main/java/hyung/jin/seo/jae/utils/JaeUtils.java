package hyung.jin.seo.jae.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;

public class JaeUtils {
	
	public static SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
	public static SimpleDateFormat displayFormat = new SimpleDateFormat("yyyy-MM-dd");
	
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

	// get year from date format
	public static int getYear(String date){
		int year = 0;
		String[] parts = date.split("/");
		if(parts.length > 0){
			year = Integer.parseInt(parts[2]);
		}
		return year;
	}
	// // convert linefeed to <br/>
	// public static String fromLinefeed2Br(String msg){
	// 	String contents = StringUtils.defaultString(msg);
	// 	return contents.replaceAll("\n", "<br/>");
	// }

	// // convert <br/> to linefeed
	// public static String fromBr2Linefeed(String msg){
	// 	String contents = StringUtils.defaultString(msg);
	// 	return contents.replaceAll("<br/>", "\n");
	// }
	
}
