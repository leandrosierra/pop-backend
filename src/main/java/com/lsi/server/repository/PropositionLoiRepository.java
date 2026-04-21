package com.lsi.server.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.PropositionLoi;

@Repository
public interface PropositionLoiRepository extends JpaRepository<PropositionLoi, Long> {

	@Query("SELECT p FROM PropositionLoi p where p.question.id = :questionId order by p.dateCreation desc")
	Page<PropositionLoi> findPropositionsByQuestionId(@Param("questionId") Long questionId, Pageable pageable);

	@Query("SELECT p FROM PropositionLoi p where p.user.id = :userId order by p.dateCreation desc")
	Page<PropositionLoi> findPropositionsByUserId(@Param("userId") Long userId, Pageable pageable);
}
