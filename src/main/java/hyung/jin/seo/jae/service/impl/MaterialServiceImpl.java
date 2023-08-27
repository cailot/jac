package hyung.jin.seo.jae.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityNotFoundException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.model.Material;
import hyung.jin.seo.jae.repository.MaterialRepository;
import hyung.jin.seo.jae.service.MaterialService;

@Service
public class MaterialServiceImpl implements MaterialService {
	
	@Autowired
	private MaterialRepository materialRepository;
	
	@Override
	public long checkCount() {
		long count = materialRepository.count();
		return count;
	}

	@Override
	public List<MaterialDTO> allMaterials() {
		List<Material> materials = materialRepository.findAll();
		List<MaterialDTO> dtos = new ArrayList<>();
		for(Material material: materials){
			MaterialDTO dto = new MaterialDTO(material);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<MaterialDTO> findMaterialByInvoice(Long id) {
		List<MaterialDTO> dtos = materialRepository.findMaterialByInvoiceId(id);
		return dtos;
	}

	@Override
	public Material getMaterial(Long id) {
		Material material = materialRepository.findById(id).get();
		return material;
	}
	
	@Override
	@Transactional
	public Material addMaterial(Material material) {
		Material add = materialRepository.save(material);
		return add;
	}

	@Override
	@Transactional
	public Material updateMaterial(Material stand, Long id) {
		// search by getId
		Material existing = materialRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Material not found"));
		// Update the existing record
		// paymentDate
		LocalDate newPaymentDate = stand.getPaymentDate();
		existing.setPaymentDate(newPaymentDate);
		// info
		if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(stand.getInfo()), StringUtils.defaultString(existing.getInfo()))){
			existing.setInfo(StringUtils.defaultString(stand.getInfo()));
		}
		// update the existing record
		Material updated = materialRepository.save(existing);
		return updated;	
	}

	@Override
	@Transactional
	public void deleteMaterial(Long invoiceId, Long bookId) {
		//materialRepository.deleteMaterial(invoiceId, bookId);
		materialRepository.deleteMaterialByInvoiceIdAndBookId(invoiceId, bookId);
	}
}
