sc = Scorecard.first
subjects = sc.subjects
citeria_sets = subjects.map(&:criteria_sets).flatten
citeria = criteria_sets.map(&:criteria).flatten
indicators = criteria.map(&:indicators).flatten

ActiveRecordArchiver.export(sc, subjects, criteria_sets, criteria,
                            indicators => [:title, :description])

