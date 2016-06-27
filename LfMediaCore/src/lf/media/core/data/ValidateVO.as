package lf.media.core.data
{
	public class ValidateVO
	{
		public var isOk:Boolean = false;
		public var data:Object = null;
		
		public function ValidateVO(isOk:Boolean,data:Object){
			this.isOk = isOk;
			this.data = data;
		}
		
		
	}
}