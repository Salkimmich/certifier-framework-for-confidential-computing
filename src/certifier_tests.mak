#    
#    File: certifier_tests.mak

#ENABLE_SEV=1
#RUN_SEV_TESTS=1

# CERTIFIER_ROOT will be certifier-framework-for-confidential-computing/ dir
CERTIFIER_ROOT = ..

ifndef SRC_DIR
SRC_DIR=.
endif
ifndef INC_DIR
INC_DIR=../include
endif
ifndef OBJ_DIR
OBJ_DIR=.
endif
ifndef EXE_DIR
EXE_DIR=.
endif

#ifndef GOOGLE_INCLUDE
#GOOGLE_INCLUDE=/usr/local/include/google
#endif

LOCAL_LIB=/usr/local/lib

ifndef TARGET_MACHINE_TYPE
TARGET_MACHINE_TYPE= x64
endif

CP = $(CERTIFIER_ROOT)/certifier_service/certprotos

S= $(SRC_DIR)
O= $(OBJ_DIR)
I= $(INC_DIR)

INCLUDE = -I $(I) -I/usr/local/opt/openssl@1.1/include/ -I $(S)/sev-snp -I $(S)/gramine

CFLAGS_COMMON = $(INCLUDE) -g -std=c++11 -D X64 -Wall -Wno-unused-variable -Wno-deprecated-declarations

CFLAGS  = $(CFLAGS_COMMON) -O3

ifdef ENABLE_SEV

CFLAGS  += -D SEV_SNP -D SEV_DUMMY_GUEST

ifdef RUN_SEV_TESTS
CFLAGS  += -D RUN_SEV_TESTS
endif

endif

CC=g++
LINK=g++
# Point this to the right place, if you have to, based on your machine's install:
# PROTO=/usr/local/bin/protoc
PROTO=protoc
AR=ar
#export LD_LIBRARY_PATH=/usr/local/lib
LDFLAGS= -L $(LOCAL_LIB) -lprotobuf -lgtest -lgflags -lpthread -L/usr/local/opt/openssl@1.1/lib/ -lcrypto -lssl

# ----------------------------------------------------------------------
# Define list of objects for common case which will be extended for
# ENABLE_SEV build mode.
# ----------------------------------------------------------------------
common_objs = $(O)/certifier.pb.o $(O)/certifier.o      \
              $(O)/certifier_proofs.o  $(O)/support.o $(O)/simulated_enclave.o \
              $(O)/application_enclave.o

dobj = $(O)/certifier_tests.o $(common_objs) \
       $(O)/cc_helpers.o $(O)/cc_useful.o \
       $(O)/claims_tests.o $(O)/primitive_tests.o $(O)/certificate_tests.o       \
       $(O)/store_tests.o $(O)/support_tests.o $(O)/x509_tests.o

channel_dobj = $(O)/test_channel.o $(common_objs) \
               $(O)/cc_helpers.o $(O)/cc_useful.o

pipe_read_dobj = $(O)/pipe_read_test.o $(common_objs)

ifdef ENABLE_SEV
sev_common_objs = $(O)/sev_support.o $(O)/sev_report.o

dobj +=	$(O)/sev_tests.o $(sev_common_objs)

channel_dobj += $(sev_common_objs)

pipe_read_dobj += $(sev_common_objs)
endif

all:	certifier_tests.exe test_channel.exe pipe_read_test.exe

clean:
	@echo "removing generated files"
	rm -rf $(S)/certifier.pb.h $(I)/certifier.pb.h $(S)/certifier.pb.cc
	@echo "removing object files"
	rm -rf $(O)/*.o
	@echo "removing executable files"
	rm -rf $(EXE_DIR)/certifier_tests.exe $(EXE_DIR)/pipe_read_test.exe $(EXE_DIR)/test_channel.exe

certifier_tests.exe: $(dobj) 
	@echo "\nlinking executable files"
	$(LINK) -o $(EXE_DIR)/certifier_tests.exe $(dobj) $(LDFLAGS)

$(I)/certifier.pb.h: $(S)/certifier.pb.cc
$(S)/certifier.pb.cc: $(CP)/certifier.proto
	$(PROTO) --cpp_out=$(S) --proto_path $(<D) $<
	mv $(S)/certifier.pb.h $(I)

$(O)/support_tests.o: $(S)/support_tests.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/store_tests.o: $(S)/store_tests.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/primitive_tests.o: $(S)/primitive_tests.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/x509_tests.o: $(S)/x509_tests.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/certificate_tests.o: $(S)/certificate_tests.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/claims_tests.o: $(S)/claims_tests.cc $(I)/certifier.pb.h $(I)/certifier.h $(S)/test_support.cc
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/sev_tests.o: $(S)/sev_tests.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/certifier_tests.o: $(S)/certifier_tests.cc $(I)/certifier.pb.h $(I)/certifier.h $(S)/test_support.cc
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/certifier.pb.o: $(S)/certifier.pb.cc $(I)/certifier.pb.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/certifier.o: $(S)/certifier.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/certifier_proofs.o: $(S)/certifier_proofs.cc $(I)/certifier.pb.h $(I)/certifier.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/cc_helpers.o: $(S)/cc_helpers.cc $(I)/certifier.pb.h $(I)/cc_helpers.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/cc_useful.o: $(S)/cc_useful.cc $(I)/cc_useful.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/support.o: $(S)/support.cc $(I)/support.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/simulated_enclave.o: $(S)/simulated_enclave.cc $(I)/simulated_enclave.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/application_enclave.o: $(S)/application_enclave.cc $(I)/application_enclave.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

ifdef ENABLE_SEV
SEV_S=$(S)/sev-snp

$(O)/sev_support.o: $(SEV_S)/sev_support.cc \
$(I)/certifier.h $(I)/support.h $(SEV_S)/attestation.h  $(SEV_S)/sev_guest.h  \
$(SEV_S)/snp_derive_key.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

$(O)/sev_report.o: $(SEV_S)/sev_report.cc \
$(I)/certifier.h $(I)/support.h $(SEV_S)/attestation.h  $(SEV_S)/sev_guest.h  \
$(SEV_S)/snp_derive_key.h
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<
endif

pipe_read_test.exe: $(pipe_read_dobj) 
	@echo "\nlinking executable files"
	$(LINK) -o $(EXE_DIR)/pipe_read_test.exe $(pipe_read_dobj) $(LDFLAGS)

$(O)/pipe_read_test.o: $(S)/pipe_read_test.cc
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<

test_channel.exe: $(channel_dobj) 
	@echo "\nlinking executable files"
	$(LINK) -o $(EXE_DIR)/test_channel.exe $(channel_dobj) $(LDFLAGS)

$(O)/test_channel.o: $(S)/test_channel.cc
	@echo "\ncompiling $<"
	$(CC) $(CFLAGS) -o $(@D)/$@ -c $<
