.PHONY: install up build test q serve-mf lint clean

install:
	pip install -r requirements.txt

up: install
	@test -f profiles.yml || cp profiles.yml.example profiles.yml
	dbt deps --profiles-dir .
	dbt seed --profiles-dir .
	dbt build --profiles-dir .
	mf validate-configs

build:
	dbt build --profiles-dir .

test:
	dbt test --profiles-dir .

# usage: make q METRIC=nrr GROUP=metric_time__month,cohort__cohort_month
q:
	mf query --metrics $(METRIC) $(if $(GROUP),--group-by $(GROUP),)

serve-mf:
	mf tutorial

lint:
	sqlfluff lint models/

clean:
	rm -rf target/ dbt_packages/ logs/
