package com.lsi.server.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.PropositionLoi;

@Repository
public interface PropositionLoiRepository extends JpaRepository<PropositionLoi, Long> {

	@Query("SELECT p FROM PropositionLoi p where p.question.id = :questionId order by p.dateCreation desc")
	List<PropositionLoi> findPropositionsByQuestionId(@Param("questionId") Long questionId);

	@Query("SELECT p FROM PropositionLoi p where p.user.id = :userId order by p.dateCreation desc")
	List<PropositionLoi> findPropositionsByUserId(@Param("userId") Long userId);
}
