import java.io.*;

public class GitHelper {

    public static StringBuilder gitClone(String repoUrl, File gitDir) {
        String[] gitClone = {"git", "clone", repoUrl};
        executeGitCommand(gitDir, gitClone);
        String newDirName = repoUrl.substring(repoUrl.lastIndexOf("/") + 1, repoUrl.lastIndexOf("."));
        StringBuilder output = new StringBuilder();
        output.append(gitDir.toPath() + "/" + newDirName);
        return output;
    }

    public static StringBuilder gitCheckoutCommit(String commit, File gitDir) {
        String[] gitDiffStat = {"git", "checkout", commit};
        return executeGitCommand(gitDir, gitDiffStat);
    }

    public static StringBuilder gitRevParseHead(File gitDir) {
        String[] gitDiffStat = {"git", "rev-parse", "HEAD"};
        return executeGitCommand(gitDir, gitDiffStat);
    }

    public static StringBuilder gitDiffNameStatus(String commit1, String commit2, File gitDir) {
        String[] gitDiffStat = {"git", "diff", "--name-status", commit1, commit2};
        return executeGitCommand(gitDir, gitDiffStat);
    }

    public static StringBuilder gitDiffNumStat(String commit1, String commit2, File gitDir) {
        String[] gitDiffStat = {"git", "diff", "--numstat", commit1, commit2};
        return executeGitCommand(gitDir, gitDiffStat);
    }

    public static StringBuilder executeGitCommand(File gitDir, String... args) {
        StringBuilder output = new StringBuilder();

        StringBuilder argsStringBuilder = new StringBuilder();
        for (String arg : args) {
            argsStringBuilder.append(arg + " ");
        }
        System.out.println("Executing git command " + argsStringBuilder.toString() + "in " + gitDir.toPath());

        ProcessBuilder processBuilder = new ProcessBuilder().command(args).directory(gitDir);
        File file = new File("out.txt");
        file.deleteOnExit();
        processBuilder.redirectOutput(ProcessBuilder.Redirect.to(file));

        try {
            Process process = processBuilder.start();
            int exitCode = process.waitFor();

            if (exitCode == 0) {
                System.out.println("Git command finished with exit code 0.");

                BufferedReader reader = new BufferedReader(new FileReader(file));
                while (reader.ready()) {
                    String line = reader.readLine().trim();
                    output.append(line + "\n");
                }
                // Remove last "\n"
                if (!output.toString().isEmpty()) {
                    output.delete(output.length() - 1, output.length());
                }
            }
            process.destroy();
        } catch (IOException | InterruptedException e) {
            System.err.println("Error while executing git command: " + e);
        }
        return output;
    }

}
