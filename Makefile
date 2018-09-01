include Makefile.common

all:	$(STAGE_DIR)/cd.iso

clean: clean-img-base clean-img-build clean-img-live


.docker-img-build: .docker-img-base
.docker-img-live: .docker-img-base

.docker-img-%:	Dockerfile.%
	docker build -t $(IMG_PREFIX)-$(subst Dockerfile.,,$<) -f $< .
	touch $@

clean-img-%:
	test -f .docker-img-$(subst clean-img-,,$@) && docker rmi $(IMG_PREFIX)-$(subst clean-img-,,$@) || true
	rm -f .docker-img-$(subst clean-img-,,$@)


$(STAGE_DIR)/cd.iso: $(STAGE_DIR)/fs.tar

$(STAGE_DIR)/fs.tar: .docker-img-live
	mkdir -p $(STAGE_DIR)
	docker run --name $(IMG_PREFIX)-fs $(IMG_PREFIX)-live
	docker export -o $@ $(IMG_PREFIX)-fs
	docker rm $(IMG_PREFIX)-fs

# TODO: only the necessary --cap-add for loopback mount
$(STAGE_DIR)/%: .docker-img-build Makefile.inner
	docker run --privileged --rm -w /work -v $(shell pwd):/work $(IMG_PREFIX)-build make -f Makefile.inner $@
