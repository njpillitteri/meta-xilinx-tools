inherit xsctapp xsctyaml

B = "${S}/${XSCTH_PROJ}"

BOOTBIN_BIF_FRAGMENT_zynqmp = "destination_cpu=pmu"

XSCTH_MISC_append_zynqmpdr = " -lib libmetal"

XSCTH_COMPILER_DEBUG_FLAGS = "-DDEBUG_MODE -DXPFW_DEBUG_DETAILED"
XSCTH_PROC = "psu_pmu_0"
XSCTH_APP  = "ZynqMP PMU Firmware"

ULTRA96_VERSION ?= "1"
YAML_COMPILER_FLAGS_append = " -DENABLE_SCHEDULER "
YAML_COMPILER_FLAGS_append_ultra96 = " -DENABLE_MOD_ULTRA96 ${@bb.utils.contains('ULTRA96_VERSION', '2', ' -DULTRA96_VERSION=2 ', ' -DULTRA96_VERSION=1 ', d)}"

# XSCT version provides it's own toolchain, so can build in any environment
COMPATIBLE_HOST_zynqmp = "${HOST_SYS}"

# Clear this for a Linux build, using the XSCT toolchain
EXTRA_OEMAKE_linux = ""

# Workaround for hardcoded toolchain items
XSCT_PATH_ADD_append_elf = "\
${WORKDIR}/bin:"

MB_OBJCOPY = "mb-objcopy"

do_compile_prepend_elf() {
  mkdir -p ${WORKDIR}/bin
  echo "#! /bin/bash\n${CC} \$@" > ${WORKDIR}/bin/mb-gcc
  echo "#! /bin/bash\n${AS} \$@" > ${WORKDIR}/bin/mb-as
  echo "#! /bin/bash\n${AR} \$@" > ${WORKDIR}/bin/mb-ar
  echo "#! /bin/bash\n${OBJCOPY} \$@" > ${WORKDIR}/bin/mb-objcopy
  chmod 0755 ${WORKDIR}/bin/mb-gcc
  chmod 0755 ${WORKDIR}/bin/mb-as
  chmod 0755 ${WORKDIR}/bin/mb-ar
  chmod 0755 ${WORKDIR}/bin/mb-objcopy
}

do_compile_append() {
  ${MB_OBJCOPY} -O binary ${B}/${XSCTH_PROJ}/executable.elf ${B}/${XSCTH_PROJ}/executable.bin
}

# xsctapp sets it's own do_install, replace it with the real one
do_install() {
    :
}

do_deploy() {
    install -Dm 0644 ${B}/${XSCTH_PROJ}/executable.elf ${DEPLOYDIR}/${PMU_FIRMWARE_BASE_NAME}.elf
    ln -sf ${PMU_FIRMWARE_BASE_NAME}.elf ${DEPLOYDIR}/${PMU_FIRMWARE_IMAGE_NAME}.elf
    install -m 0644 ${B}/${XSCTH_PROJ}/executable.bin ${DEPLOYDIR}/${PMU_FIRMWARE_BASE_NAME}.bin
    ln -sf ${PMU_FIRMWARE_BASE_NAME}.bin ${DEPLOYDIR}/${PMU_FIRMWARE_IMAGE_NAME}.bin
}
