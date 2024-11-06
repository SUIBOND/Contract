#[test_only]
module suibond::suibond_tests {
    // uncomment this line to import the module
    use suibond::suibond;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_suibond() {

        // pass
    }

    #[test, expected_failure(abort_code = ::suibond::suibond_tests::ENotImplemented)]
    fun test_suibond_fail() {
        abort ENotImplemented
    }

}