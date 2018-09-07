import java.io.File;
import java.util.HashSet;
import java.util.Set;

public class PatchStats {

    private Set<String> changedFiles;
    private Set<String> addedFiles;
    private Set<String> deletedFiles;
    private int nbAddedLines;
    private int nbDeletedLines;

    PatchStats() {
        this.changedFiles = new HashSet<>();
        this.addedFiles = new HashSet<>();
        this.deletedFiles = new HashSet<>();
        this.nbAddedLines = 0;
        this.nbDeletedLines = 0;
    }

    public Set<String> getChangedFiles() {
        return changedFiles;
    }

    public Set<String> getAddedFiles() {
        return addedFiles;
    }

    public Set<String> getDeletedFiles() {
        return deletedFiles;
    }

    public int getNbAddedLines() {
        return nbAddedLines;
    }

    public int getNbDeletedLines() {
        return nbDeletedLines;
    }

    public void computeFiles(String commit1, String commit2, File gitDir) {
        StringBuilder gitOutput = GitHelper.gitDiffNameStatus(commit1, commit2, gitDir);
        String[] lines = gitOutput.toString().split("\n");
        for (String line : lines) {
            String[] aux = line.split("\t");
            if (aux.length == 2) {
                String status = aux[0];
                String fileName = aux[1];
                if (status.equals("M")) {
                    this.changedFiles.add(fileName);
                } else if (status.equals("A")) {
                    this.addedFiles.add(fileName);
                } else if (status.equals("D")) {
                    this.deletedFiles.add(fileName);
                }
            }
        }
    }

    public void computeLines(String commit1, String commit2, File gitDir) {
        StringBuilder gitOutput = GitHelper.gitDiffNumStat(commit1, commit2, gitDir);
        String[] lines = gitOutput.toString().split("\n");
        for (String line : lines) {
            String[] aux = line.split("\t");
            if (aux.length == 3) {
                this.nbAddedLines += Integer.parseInt(aux[0]);
                this.nbDeletedLines += Integer.parseInt(aux[1]);
            }
        }
    }

}
