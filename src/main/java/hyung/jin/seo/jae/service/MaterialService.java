package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.model.Material;

public interface MaterialService {
	// list all Materials
	List<MaterialDTO> allMaterials();
	
	// list Materials based on invoice Id
	List<MaterialDTO> findMaterialByInvoice(Long id);

	// get Material by Id
	Material getMaterial(Long id);

	// add Material
	Material addMaterial(Material material);

	// update Material
	Material updateMaterial(Material stand, Long id);

	// delete Material
	void deleteMaterial(Long invoiceId, Long bookId);

	// return total count
	long checkCount();


}
