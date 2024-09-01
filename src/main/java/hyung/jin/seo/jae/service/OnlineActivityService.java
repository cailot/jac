
package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.OnlineActivityDTO;
import hyung.jin.seo.jae.model.OnlineActivity;

public interface OnlineActivityService {
	
	// save activty entry
	void addOnlineActivity(Long studentId, Long onlineSessionId);

	OnlineActivity getOnlineActivity(Long studentId, Long onlineSessionId);
	
	OnlineActivity updateOnlineActivity(OnlineActivity activity, Long id);

	List<OnlineActivityDTO> getStudentStatus(Long studentId, int week);
}
