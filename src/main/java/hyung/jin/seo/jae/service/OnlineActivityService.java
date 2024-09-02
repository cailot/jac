
package hyung.jin.seo.jae.service;

import hyung.jin.seo.jae.dto.OnlineActivityDTO;
import hyung.jin.seo.jae.dto.OnlineSessionDTO;
import hyung.jin.seo.jae.model.OnlineActivity;

public interface OnlineActivityService {
	
	// save activty entry
	void addOnlineActivity(Long studentId, Long onlineSessionId);

	OnlineActivity getOnlineActivity(Long studentId, Long onlineSessionId);
	
	OnlineActivity updateOnlineActivity(OnlineActivity activity, Long id);

	// return OnlineActivityDTO by studentId & sessionId
	OnlineActivityDTO getStudentStatus(Long studentId, OnlineSessionDTO session);

}
