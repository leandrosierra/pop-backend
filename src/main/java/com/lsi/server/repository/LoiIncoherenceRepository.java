package com.lsi.server.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.LoiIncoherence;

@Repository
public interface LoiIncoherenceRepository extends JpaRepository<LoiIncoherence, Long> {

	@Query("SELECT i FROM LoiIncoherence i order by i.dateCreation desc")
	Page<LoiIncoherence> findIncoherencesRecentes(Pageable pageable);

	@Query("SELECT i FROM LoiIncoherence i where i.loi.id = :loiId or i.loiReference.id = :loiId order by i.dateCreation desc")
	Page<LoiIncoherence> findIncoherencesByLoiId(@Param("loiId") Long loiId, Pageable pageable);
}
