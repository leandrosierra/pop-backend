package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.Budget;

@Repository
public interface BudgetRepository extends JpaRepository<Budget, Long> {

	@Query("SELECT b FROM Budget b where b.niveau = :niveau and b.codeTerritoire = :codeTerritoire order by b.annee desc")
	List<Budget> findBudgetsByTerritoire(@Param("niveau") String niveau, @Param("codeTerritoire") String codeTerritoire);
}
