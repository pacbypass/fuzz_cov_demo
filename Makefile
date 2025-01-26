CC = clang++-18
CFLAGS = -g -fsanitize=fuzzer,address -fprofile-instr-generate -fcoverage-mapping
TARGET = fuzzer
CORPUS_DIR = corpus
CRASH_DIR = crashes
COVERAGE_DIR = coverage_report
LLVM_PROFDATA = llvm-profdata-18
LLVM_COV = llvm-cov-18

build:
	$(CC) $(CFLAGS) example.cpp -o $(TARGET)

fuzz: build
	mkdir -p $(CORPUS_DIR) $(CRASH_DIR)
	./$(TARGET) -max_total_time=60 -artifact_prefix=$(CRASH_DIR)/ $(CORPUS_DIR)/

coverage: build
	mkdir -p $(CORPUS_DIR) $(CRASH_DIR)
	# Run corpus-only coverage collection
	LLVM_PROFILE_FILE="$(CORPUS_DIR)/%p.profraw" \
	  ./$(TARGET) -runs=1 -shuffle=0 -close_fd_mask=3 $(CORPUS_DIR)
	# Merge and generate report
	$(LLVM_PROFDATA) merge -sparse corpus/*.profraw -o merged.profdata
	$(LLVM_COV) show $(TARGET) -instr-profile=merged.profdata --format=html -output-dir=$(COVERAGE_DIR)

clean:
	rm -rf $(TARGET) $(CORPUS_DIR) $(CRASH_DIR) $(COVERAGE_DIR) *.profraw *.profdata