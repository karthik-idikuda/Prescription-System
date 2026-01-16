// Comprehensive list of common medicines
class MedicineData {
  static const List<Map<String, String>> medicines = [
    // Pain Relief & Anti-inflammatory
    {'name': 'Paracetamol', 'category': 'Analgesic'},
    {'name': 'Ibuprofen', 'category': 'NSAID'},
    {'name': 'Aspirin', 'category': 'NSAID'},
    {'name': 'Diclofenac', 'category': 'NSAID'},
    {'name': 'Naproxen', 'category': 'NSAID'},
    {'name': 'Tramadol', 'category': 'Analgesic'},
    {'name': 'Celecoxib', 'category': 'NSAID'},
    {'name': 'Ketorolac', 'category': 'NSAID'},
    {'name': 'Etoricoxib', 'category': 'NSAID'},
    {'name': 'Mefenamic Acid', 'category': 'NSAID'},

    // Antibiotics
    {'name': 'Amoxicillin', 'category': 'Antibiotic'},
    {'name': 'Azithromycin', 'category': 'Antibiotic'},
    {'name': 'Ciprofloxacin', 'category': 'Antibiotic'},
    {'name': 'Cephalexin', 'category': 'Antibiotic'},
    {'name': 'Doxycycline', 'category': 'Antibiotic'},
    {'name': 'Metronidazole', 'category': 'Antibiotic'},
    {'name': 'Levofloxacin', 'category': 'Antibiotic'},
    {'name': 'Cefixime', 'category': 'Antibiotic'},
    {'name': 'Clindamycin', 'category': 'Antibiotic'},
    {'name': 'Erythromycin', 'category': 'Antibiotic'},
    {'name': 'Clarithromycin', 'category': 'Antibiotic'},
    {'name': 'Amoxicillin + Clavulanate', 'category': 'Antibiotic'},
    {'name': 'Ceftriaxone', 'category': 'Antibiotic'},
    {'name': 'Ofloxacin', 'category': 'Antibiotic'},

    // Antacids & GI
    {'name': 'Omeprazole', 'category': 'PPI'},
    {'name': 'Pantoprazole', 'category': 'PPI'},
    {'name': 'Ranitidine', 'category': 'H2 Blocker'},
    {'name': 'Rabeprazole', 'category': 'PPI'},
    {'name': 'Esomeprazole', 'category': 'PPI'},
    {'name': 'Domperidone', 'category': 'Antiemetic'},
    {'name': 'Ondansetron', 'category': 'Antiemetic'},
    {'name': 'Metoclopramide', 'category': 'Antiemetic'},
    {'name': 'Loperamide', 'category': 'Antidiarrheal'},
    {'name': 'Lactulose', 'category': 'Laxative'},
    {'name': 'Bisacodyl', 'category': 'Laxative'},

    // Cold & Cough
    {'name': 'Cetirizine', 'category': 'Antihistamine'},
    {'name': 'Loratadine', 'category': 'Antihistamine'},
    {'name': 'Fexofenadine', 'category': 'Antihistamine'},
    {'name': 'Chlorpheniramine', 'category': 'Antihistamine'},
    {'name': 'Pseudoephedrine', 'category': 'Decongestant'},
    {'name': 'Dextromethorphan', 'category': 'Antitussive'},
    {'name': 'Guaifenesin', 'category': 'Expectorant'},
    {'name': 'Bromhexine', 'category': 'Mucolytic'},
    {'name': 'Ambroxol', 'category': 'Mucolytic'},
    {'name': 'Levosalbutamol', 'category': 'Bronchodilator'},

    // Cardiovascular
    {'name': 'Amlodipine', 'category': 'Calcium Channel Blocker'},
    {'name': 'Atenolol', 'category': 'Beta Blocker'},
    {'name': 'Metoprolol', 'category': 'Beta Blocker'},
    {'name': 'Enalapril', 'category': 'ACE Inhibitor'},
    {'name': 'Losartan', 'category': 'ARB'},
    {'name': 'Telmisartan', 'category': 'ARB'},
    {'name': 'Atorvastatin', 'category': 'Statin'},
    {'name': 'Rosuvastatin', 'category': 'Statin'},
    {'name': 'Clopidogrel', 'category': 'Antiplatelet'},
    {'name': 'Ramipril', 'category': 'ACE Inhibitor'},
    {'name': 'Bisoprolol', 'category': 'Beta Blocker'},
    {'name': 'Furosemide', 'category': 'Diuretic'},
    {'name': 'Hydrochlorothiazide', 'category': 'Diuretic'},
    {'name': 'Spironolactone', 'category': 'Diuretic'},

    // Diabetes
    {'name': 'Metformin', 'category': 'Antidiabetic'},
    {'name': 'Glimepiride', 'category': 'Antidiabetic'},
    {'name': 'Gliclazide', 'category': 'Antidiabetic'},
    {'name': 'Sitagliptin', 'category': 'DPP-4 Inhibitor'},
    {'name': 'Vildagliptin', 'category': 'DPP-4 Inhibitor'},
    {'name': 'Empagliflozin', 'category': 'SGLT2 Inhibitor'},
    {'name': 'Dapagliflozin', 'category': 'SGLT2 Inhibitor'},
    {'name': 'Insulin Glargine', 'category': 'Insulin'},
    {'name': 'Insulin Aspart', 'category': 'Insulin'},
    {'name': 'Pioglitazone', 'category': 'Antidiabetic'},

    // Vitamins & Supplements
    {'name': 'Vitamin D3', 'category': 'Vitamin'},
    {'name': 'Vitamin B12', 'category': 'Vitamin'},
    {'name': 'Vitamin C', 'category': 'Vitamin'},
    {'name': 'Folic Acid', 'category': 'Vitamin'},
    {'name': 'Calcium Carbonate', 'category': 'Supplement'},
    {'name': 'Iron Supplement', 'category': 'Supplement'},
    {'name': 'Multivitamin', 'category': 'Supplement'},
    {'name': 'Zinc Sulfate', 'category': 'Supplement'},
    {'name': 'Omega-3', 'category': 'Supplement'},

    // Antidepressants & Psychiatric
    {'name': 'Sertraline', 'category': 'Antidepressant'},
    {'name': 'Escitalopram', 'category': 'Antidepressant'},
    {'name': 'Fluoxetine', 'category': 'Antidepressant'},
    {'name': 'Alprazolam', 'category': 'Anxiolytic'},
    {'name': 'Clonazepam', 'category': 'Anxiolytic'},
    {'name': 'Diazepam', 'category': 'Anxiolytic'},
    {'name': 'Lorazepam', 'category': 'Anxiolytic'},
    {'name': 'Quetiapine', 'category': 'Antipsychotic'},
    {'name': 'Risperidone', 'category': 'Antipsychotic'},
    {'name': 'Olanzapine', 'category': 'Antipsychotic'},

    // Anticonvulsants
    {'name': 'Pregabalin', 'category': 'Anticonvulsant'},
    {'name': 'Gabapentin', 'category': 'Anticonvulsant'},
    {'name': 'Carbamazepine', 'category': 'Anticonvulsant'},
    {'name': 'Phenytoin', 'category': 'Anticonvulsant'},
    {'name': 'Valproate', 'category': 'Anticonvulsant'},
    {'name': 'Levetiracetam', 'category': 'Anticonvulsant'},

    // Thyroid
    {'name': 'Levothyroxine', 'category': 'Thyroid'},
    {'name': 'Carbimazole', 'category': 'Thyroid'},
    {'name': 'Propylthiouracil', 'category': 'Thyroid'},

    // Steroids
    {'name': 'Prednisolone', 'category': 'Steroid'},
    {'name': 'Dexamethasone', 'category': 'Steroid'},
    {'name': 'Hydrocortisone', 'category': 'Steroid'},
    {'name': 'Methylprednisolone', 'category': 'Steroid'},
    {'name': 'Betamethasone', 'category': 'Steroid'},

    // Antivirals & Antifungals
    {'name': 'Acyclovir', 'category': 'Antiviral'},
    {'name': 'Oseltamivir', 'category': 'Antiviral'},
    {'name': 'Fluconazole', 'category': 'Antifungal'},
    {'name': 'Itraconazole', 'category': 'Antifungal'},
    {'name': 'Ketoconazole', 'category': 'Antifungal'},
    {'name': 'Terbinafine', 'category': 'Antifungal'},

    // Eye/Ear Drops
    {'name': 'Moxifloxacin Eye Drops', 'category': 'Ophthalmic'},
    {'name': 'Timolol Eye Drops', 'category': 'Ophthalmic'},
    {'name': 'Latanoprost Eye Drops', 'category': 'Ophthalmic'},
    {'name': 'Ciprofloxacin Ear Drops', 'category': 'Otic'},
    {'name': 'Carboxymethylcellulose Eye Drops', 'category': 'Ophthalmic'},

    // Topical
    {'name': 'Betamethasone Cream', 'category': 'Topical'},
    {'name': 'Clotrimazole Cream', 'category': 'Topical'},
    {'name': 'Mupirocin Ointment', 'category': 'Topical'},
    {'name': 'Fusidic Acid Cream', 'category': 'Topical'},
    {'name': 'Hydrocortisone Cream', 'category': 'Topical'},
    {'name': 'Benzoyl Peroxide Gel', 'category': 'Topical'},

    // Others
    {'name': 'Allopurinol', 'category': 'Antigout'},
    {'name': 'Colchicine', 'category': 'Antigout'},
    {'name': 'Warfarin', 'category': 'Anticoagulant'},
    {'name': 'Rivaroxaban', 'category': 'Anticoagulant'},
    {'name': 'Apixaban', 'category': 'Anticoagulant'},
    {'name': 'Sildenafil', 'category': 'PDE5 Inhibitor'},
    {'name': 'Tamsulosin', 'category': 'Alpha Blocker'},
    {'name': 'Finasteride', 'category': 'Hormone'},
    {'name': 'Montelukast', 'category': 'Leukotriene Inhibitor'},
    {'name': 'Salbutamol', 'category': 'Bronchodilator'},
    {'name': 'Budesonide', 'category': 'Steroid Inhaler'},
    {'name': 'Glyceryl Trinitrate', 'category': 'Nitrate'},
    {'name': 'Isosorbide Mononitrate', 'category': 'Nitrate'},

    // Common Brand Names (India specific)
    {'name': 'Crocin', 'category': 'Analgesic'},
    {'name': 'Dolo 650', 'category': 'Analgesic'},
    {'name': 'Combiflam', 'category': 'Analgesic'},
    {'name': 'Augmentin', 'category': 'Antibiotic'},
    {'name': 'Zifi', 'category': 'Antibiotic'},
    {'name': 'Pan 40', 'category': 'PPI'},
    {'name': 'Rablet', 'category': 'PPI'},
    {'name': 'Allegra', 'category': 'Antihistamine'},
    {'name': 'Avil', 'category': 'Antihistamine'},
    {'name': 'Sinarest', 'category': 'Cold & Cough'},
    {'name': 'Vicks Action 500', 'category': 'Cold & Cough'},
    {'name': 'Norvasc', 'category': 'Calcium Channel Blocker'},
    {'name': 'Concor', 'category': 'Beta Blocker'},
    {'name': 'Gluconorm', 'category': 'Antidiabetic'},
    {'name': 'Januvia', 'category': 'DPP-4 Inhibitor'},
    {'name': 'Lipitor', 'category': 'Statin'},
    {'name': 'Crestor', 'category': 'Statin'},
    {'name': 'Lyrica', 'category': 'Anticonvulsant'},
    {'name': 'Neurontin', 'category': 'Anticonvulsant'},
  ];

  static List<Map<String, String>> search(String query) {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    return medicines.where((med) {
      final nameLower = med['name']!.toLowerCase();
      final categoryLower = med['category']!.toLowerCase();

      return nameLower.contains(queryLower) ||
          categoryLower.contains(queryLower) ||
          nameLower.startsWith(queryLower);
    }).toList();
  }
}
