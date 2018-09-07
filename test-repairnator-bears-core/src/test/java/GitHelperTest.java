import org.junit.Before;
import org.junit.Test;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import static org.junit.Assert.assertEquals;

public class GitHelperTest {

    private File tmpDir;
    private String repoUrl;

    @Before
    public void setUp() throws IOException {
        tmpDir = Files.createTempDirectory("workspace").toFile();
        repoUrl = "https://github.com/fermadeiral/bears-usage.git";
    }

    @Test
    public void testGitClone() {
        StringBuilder gitDirPath = GitHelper.gitClone(repoUrl, tmpDir);
        assertEquals(tmpDir.toPath() + "/bears-usage", gitDirPath.toString());
    }

    @Test
    public void testGitCheckoutCommit() {
        StringBuilder gitDirPath = GitHelper.gitClone(repoUrl, tmpDir);
        File gitDir = new File(gitDirPath.toString());

        String commit = "64ac432f62f9b450ffb221fb8ff2caa8e81a6663";

        GitHelper.gitCheckoutCommit(commit, gitDir);

        StringBuilder gitRevParseHeadOutput = GitHelper.gitRevParseHead(gitDir);

        assertEquals(commit, gitRevParseHeadOutput.toString());
    }

    @Test
    public void testGitDiffNameStatus() {
        StringBuilder gitDirPath = GitHelper.gitClone(repoUrl, tmpDir);

        String commit1 = "6565b62263c1a8209933587aa68dff5307abf32e";
        String commit2 = "e90c26bbfbdbdc9039090f4cd5108fc17273bf5d";

        StringBuilder gitOutput = GitHelper.gitDiffNameStatus(commit1, commit2, new File(gitDirPath.toString()));
        String[] lines = gitOutput.toString().split("\n");
        assertEquals(7, lines.length);
    }

    @Test
    public void testGitDiffNumStat() {
        StringBuilder gitDirPath = GitHelper.gitClone(repoUrl, tmpDir);

        String commit1 = "6565b62263c1a8209933587aa68dff5307abf32e";
        String commit2 = "e90c26bbfbdbdc9039090f4cd5108fc17273bf5d";

        StringBuilder gitOutput = GitHelper.gitDiffNumStat(commit1, commit2, new File(gitDirPath.toString()));
        String[] lines = gitOutput.toString().split("\n");
        assertEquals(7, lines.length);
    }

}
