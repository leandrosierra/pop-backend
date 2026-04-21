package com.lsi.server.model;

import java.util.ArrayList;
import java.util.List;

public class BudgetChoixResult {
	private BudgetChoix choix;
	private List<BudgetImpact> impacts = new ArrayList<>();

	public BudgetChoixResult(BudgetChoix choix, List<BudgetImpact> impacts) {
		this.choix = choix;
		this.impacts = impacts;
	}

	public BudgetChoix getChoix() {
		return choix;
	}

	public void setChoix(BudgetChoix choix) {
		this.choix = choix;
	}

	public List<BudgetImpact> getImpacts() {
		return impacts;
	}

	public void setImpacts(List<BudgetImpact> impacts) {
		this.impacts = impacts;
	}
}
