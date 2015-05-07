import x10.util.ArrayList;
import x10.regionarray.Region;

interface SearchEngineI {

  def createInitialTask( table: Tables, searchRegion: Region{self.rank==Simulator.numParams} ): ArrayList[Task];

  def onParameterSetFinished( table: Tables, finishedPS: ParameterSet ): ArrayList[Task];

}
