package com.lsi.server.repository;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.lsi.server.model.QuestionSuggestion;

@Repository
public interface QuestionSuggestionRepository extends JpaRepository<QuestionSuggestion, Long> {

	@Query("SELECT s FROM QuestionSuggestion s order by s.dateCreation desc")
	Page<QuestionSuggestion> findSuggestionsRecentes(Pageable pageable);

	@Query("SELECT s FROM QuestionSuggestion s where s.actualite.id = :actualiteId")
	Optional<QuestionSuggestion> findSuggestionByActualiteId(@Param("actualiteId") Long actualiteId);
}
