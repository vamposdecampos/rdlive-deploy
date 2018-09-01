IMG_PREFIX	:= centos-deploy

all:	.docker-img-build

clean: clean-img-base clean-img-build


.docker-img-build: .docker-img-base

.docker-img-%:	Dockerfile.%
	docker build -t $(IMG_PREFIX)-$(subst Dockerfile.,,$<) -f $< .
	touch $@

clean-img-%:
	test -f .docker-img-$(subst clean-img-,,$@) && docker rmi $(IMG_PREFIX)-$(subst clean-img-,,$@) || true
	rm -f .docker-img-$(subst clean-img-,,$@)
