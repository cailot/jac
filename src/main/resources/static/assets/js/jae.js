// clean up any single quote escape charater in Json
function cleanUpJson(obj){
	const jsonString = JSON.stringify(obj, (key, value) => {
  		// If the value is a string, remove escape characters from it
  		if (typeof value === 'string') {
    		return value.replace(/'/g, '&#39;');
  		}
  			return value;
	});
	return jsonString;
}

// StringUtils.isNotBlank()
function isNotBlank(value) {
	return typeof value === 'string' && value.trim().length > 0;
}
 
// String escape characters : single/double quotes, linefeed
function encodeDecodeString(str) {
	// Encoding
	let encodedStr = str
	  .replace(/\\/g, '\\\\')    // Backslash
	  .replace(/'/g, "\\'")       // Single quote
	//   .replace(/"/g, '\\"')       // Double quote
	  .replace(/"/g, "\\'")       // Double quote to single quote
	  .replace(/\n/g, '\\n');     // Line feed
  
	// Decoding
	let decodedStr = encodedStr
	  .replace(/\\n/g, '\n')      // Line feed
	  .replace(/\\"/g, '"')       // Double quote
	  .replace(/\\'/g, "'")       // Single quote
	  .replace(/\\\\/g, '\\');    // Backslash
  
	return { encoded: encodedStr, decoded: decodedStr };
  }

// format date - ex> 15/07/2023
  function getFormattedToday() {
	var date = new Date();
	var day = date.getDate();
	var month = date.getMonth() + 1; // Months are zero-based
	var year = date.getFullYear();
  
	// Add leading zeros if necessary
	if (day < 10) {
	  day = '0' + day;
	}
	if (month < 10) {
	  month = '0' + month;
	}
  
	var formattedDate = day + '/' + month + '/' + year;
	return formattedDate;
  }

 // avoid null string 
  function defaultIfEmpty(input, defaultValue) {
	if (typeof input === 'string' && input !== null && input !== '') {
	  return input;
	} else {
	  return defaultValue; // Or any other value you want to return for non-valid strings
	}
  }
  
// date format for datepicker. it changes date format from yyyy-mm-dd to dd/mm/yyyy
function formatDate(dateString) {
	if (dateString.includes('-')) {
		const parts = dateString.split('-');
		const formattedDate = parts.reverse().join('/');
		return formattedDate;
	} else {
		return dateString; // Return the original string if it doesn't contain '-'
	}
}

// Function to get URL parameters by name
function getParameterByName(name) {
    var url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

// Clear Form data
function clearFormData(elementId) {
	document.getElementById(elementId).reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	List state
function listState(selectElementId) {
	$.ajax({
		url:  '/code/state',
		type: 'GET',
		success: function (data) {
			// Update display info
			$.each(data, function (index, state) {
				var option = "<option value='" + state.value + "'>" + state.name + "</option>";
				$(selectElementId).append(option);	
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}
  
//	List branch
function listBranch(selectElementId) {
	$.ajax({
		url:  '/code/branch',
		type: 'GET',
		success: function (data) {
			$.each(data, function (index, state) {
				var option = "<option value='" + state.value + "'>" + state.name + "</option>";
				$(selectElementId).append(option);	
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//	List grade
function listGrade(selectElementId) {
	$.ajax({
		url:  '/code/grade',
		type: 'GET',
		success: function (data) {
			$.each(data, function (index, state) {
				var option = "<option value='" + state.value + "'>" + state.name + "</option>";
				$(selectElementId).append(option);	
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//	List day
function listDay(selectElementId) {
	$.ajax({
		url:  '/code/day',
		type: 'GET',
		success: function (data) {
			$.each(data, function (index, state) {
				var option = "<option value='" + state.value + "'>" + state.name + "</option>";
				$(selectElementId).append(option);	
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//	List subject
function listSubject(selectElementId) {
	$.ajax({
		url:  '/code/subject',
		type: 'GET',
		success: function (data) {
			$.each(data, function (index, state) {
				var option = "<option value='" + state.value + "'>" + state.name + "</option>";
				if(index < 9){ // subject only
					$(selectElementId).append(option);	
				}
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//	List practice type
function listPracticeType(selectElementId) {
	$.ajax({
		url:  '/code/practiceType',
		type: 'GET',
		success: function (data) {
			$.each(data, function (index, state) {
				var option = "<option value='" + state.value + "'>" + state.name + "</option>";
				$(selectElementId).append(option);	
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//	List test type
function listTestType(selectElementId) {
	$.ajax({
		url:  '/code/testType',
		type: 'GET',
		success: function (data) {
			$.each(data, function (index, state) {
				var option = "<option value='" + state.value + "'>" + state.name + "</option>";
				$(selectElementId).append(option);	
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


// table heeader branch
function headerBranch(tableElementId) {
	$.ajax({
		url:  '/code/branch',
		type: 'GET',
		success: function (data) {
			var headerRow = $("<tr></tr>"); // Create a new row for headers
			$.each(data, function (index, state) {
				var th = "<th>" + state.name + "</th>"; // Create a new table header
				headerRow.append(th); // Append the header to the row
			});
			$(tableElementId).append(headerRow); // Append the row to the table
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

// get state name
function  stateName(value){
	var stateText = '';
	switch(value) {
		case '1': stateText = 'Victoria'; break;
		case '2': stateText = 'New South Wales'; break;
		case '3': stateText = 'Queensland'; break;
		case '4': stateText = 'South Australia'; break;
		case '5': stateText = 'Tasmania'; break;
		case '6': stateText = 'Western Australia'; break;
		case '7': stateText = 'Northern Territory'; break;
		case '8': stateText = 'ACT'; break;
		default: stateText = 'All State'; 
	}
	return stateText;
}

// get branch name
function  branchName(value){
	var branchText = '';
	switch(value) {
		case '12': branchText = 'Box Hill'; break;
		case '13': branchText = 'Braybrook'; break;
		case '14': branchText = 'Chadstone'; break;
		case '15': branchText = 'Cranbourne'; break;
		case '16': branchText = 'Epping'; break;
		case '17': branchText = 'Glen Waverley'; break;
		case '18': branchText = 'Narre Warren'; break;
		case '19': branchText = 'Mitcham'; break;
		case '20': branchText = 'Preston'; break;
		case '21': branchText = 'Richmond'; break;
		case '22': branchText = 'Springvale'; break;
		case '23': branchText = 'St. Albans'; break;
		case '24': branchText = 'Werribee'; break;
		case '25': branchText = 'Balwyn'; break;
		case '26': branchText = 'Rowville'; break;
		case '27': branchText = 'Caroline Springs'; break;
		case '28': branchText = 'Bayswater'; break;
		case '29': branchText = 'Point Cook'; break;
		case '30': branchText = 'Craigieburn'; break;
		case '31': branchText = 'Mernda'; break;
		case '32': branchText = 'Melton'; break;
		case '33': branchText = 'Genroy'; break;
		case '34': branchText = 'Pakenham'; break;
		case '90': branchText = 'JAC Head Office Vic'; break;
		case '99': branchText = 'Testing'; break;
		default: branchText = 'All Branch'; 
	}
	return branchText;
}

// get grade name
function  gradeName(value){
	var gradeText = '';
	switch(value) {
		case '1': gradeText = 'P2'; break;
		case '2': gradeText = 'P3'; break;
		case '3': gradeText = 'P4'; break;
		case '4': gradeText = 'P5'; break;
		case '5': gradeText = 'P6'; break;
		case '6': gradeText = 'S7'; break;
		case '7': gradeText = 'S8'; break;
		case '8': gradeText = 'S9'; break;
		case '9': gradeText = 'S10'; break;
		case '10': gradeText = 'S10E'; break;
		case '11': gradeText = 'TT6'; break;
		case '12': gradeText = 'TT8'; break;
		case '13': gradeText = 'TT8E'; break;
		case '14': gradeText = 'SRW4'; break;
		case '15': gradeText = 'SRW5'; break;
		case '16': gradeText = 'SRW6'; break;
		case '17': gradeText = 'SRW7'; break;
		case '18': gradeText = 'SRW8'; break;
		case '19': gradeText = 'JMSS'; break;
		case '20': gradeText = 'VCE'; break;
		default: gradeText = 'All'; 
	}
	return gradeText;
}

// get day name
function  dayName(value){
	var dayText = '';
	switch(value) {
		case '0': dayText = 'All'; break;
		case '1': dayText = 'Monday'; break;
		case '2': dayText = 'Tuesday'; break;
		case '3': dayText = 'Wednesday'; break;
		case '4': dayText = 'Thursday'; break;
		case '5': dayText = 'Friday'; break;
		case '6': dayText = 'SATAM'; break;
		case '7': dayText = 'SATPM'; break;
		case '8': dayText = 'SUNAM'; break;
		case '9': dayText = 'SUNPM'; break;
	}
	return dayText;
}

// payment name
function  paymentName(value){
	var payText = '';
	switch(value) {
		case '0': payText = 'All'; break;
		case 'cash': payText = 'Cash'; break;
		case 'cheque': payText = 'Cheque'; break;
		case 'card': payText = 'Card'; break;
		case 'bank': payText = 'Bank'; break;
	}
	return payText;
}

// get day code
function dayCode(value){
	var day = '';
	switch(value) {
		case 'All': day = '0'; break;
		case 'Monday': day = '1'; break;
		case 'Tuesday': day = '2'; break;
		case 'Wednesday': day = '3'; break;
		case 'Thursday': day = '4'; break;
		case 'Friday': day = '5'; break;
		case 'SATAM': day = '6'; break;
		case 'SATPM': day = '7'; break;
		case 'SUNAM': day = '8'; break;
		case 'SUNPM': day = '9'; break;
	}
	return day;
}

// get subject name
function subjectName(value){
	var subjectText = '';
	switch(value) {
		case '1': subjectText = 'English'; break;
		case '2': subjectText = 'Maths'; break;
		case '3': subjectText = 'English'; break;
		case '4': subjectText = 'Writing'; break;
		case '5': subjectText = 'Science'; break;
		case '12': subjectText = 'Short Answer'; break;
//		case '13': subjectText = 'Short Answer TT'; break;
		default: subjectText = 'All'; 
	}
	return subjectText;
}

// get practice group name
function  practiceGroupName(value){
	var groupText = '';
	switch(value) {
		case '1': groupText = 'Mega Practice'; break;
		case '2': groupText = 'Revision Practice'; break;
		case '3': groupText = 'Edu Practice'; break;
		case '4': groupText = 'Acer Practice'; break;
		case '5': groupText = 'Naplan Practice'; break;
		default: groupText = 'All'; 
	}
	return groupText;
}

// get test group name
function  testGroupName(value){
	var groupText = '';
	switch(value) {
		case '1': groupText = 'Mega Test'; break;
		case '2': groupText = 'Revision Test'; break;
		case '3': groupText = 'Edu Test'; break;
		case '4': groupText = 'Acer Test'; break;
		case '5': groupText = 'Mock Test'; break;
		default: groupText = 'All'; 
	}
	return groupText;
}

// get answer by number
function  answerName(value){
	var groupText = '';
	switch(value) {
		case 1: groupText = 'A'; break;
		case 2: groupText = 'B'; break;
		case 3: groupText = 'C'; break;
		case 4: groupText = 'D'; break;
		case 5: groupText = 'E'; break;
		default: groupText = ''; 
	}
	return groupText;
}

// get the context path dynamically
function getContextPath(){
	var contextPath = window.location.pathname.split('/')[1];
	return '/'  + contextPath;
}