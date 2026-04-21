package com.lsi.server.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Actualite;

@Repository
public interface ActualiteRepository extends JpaRepository<Actualite, Long> {

	@Query("SELECT a FROM Actualite a order by a.datePublication desc")
	Page<Actualite> findActualitesRecentes(Pageable pageable);
}
