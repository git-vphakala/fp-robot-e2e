class FindPairsTestLibrary:

    def check_scores(self, actual, expected):
        print(actual, expected)
        assert len(actual) == len(expected), 'len invalid'
        for i, val in enumerate(actual):
            assert val == expected[i]
