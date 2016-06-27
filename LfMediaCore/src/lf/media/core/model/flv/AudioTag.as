package lf.media.core.model.flv
{
	import flash.utils.ByteArray;
	
	/**
	 * Audio Tag
	 * tag len=  tag head(11) + tag data
	 */
	public class AudioTag
	{
		public var data:ByteArray = null;
		public  const headLen:int = 11;
		private var _size:Number = 0;
		
		public function AudioTag()
		{
		}
		
		
		//在当前ByteArray  中的起始位置
		public var pos:Number = 0;
		
		public function set size(value:Number):void{
			_size = value;  
		}
		
		public function get size():Number{
			return _size;
		}
		
		public function get tagLen():Number{
			//taghead len  +  data size  + pre tag size
			return headLen+_size+4;
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