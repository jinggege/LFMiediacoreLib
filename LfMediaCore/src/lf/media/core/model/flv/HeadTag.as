package lf.media.core.model.flv
{
	import flash.utils.ByteArray;

	public class HeadTag
	{
		
		public var pos:Number = 0;
		public var HeadTagLen:int = 9;
		
		public var data:ByteArray = null;
		
		public function HeadTag()
		{
		}
		
		
		public function get size():int{
			//head len + first tag size
			return HeadTagLen + 4;
		}
		
		
		
		public function print():void{
			if(data){
				var s:String = "";
				for(var i:int=0; i<data.bytesAvailable; i++){
					s += data[i].toString(16)+"|";
				}
				trace(s);
			}
		
		}
		
		
		
		public function destroy():void{
			if(data){
				data.clear();
			}
			data = null;
		}
		
		
		
		
		
	}
}