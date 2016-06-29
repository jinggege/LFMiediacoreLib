package lf.media.core.model.flv
{
	import flash.utils.ByteArray;
	
	/**
	 * Audio Tag
	 * tag len=  tag head(11) + tag data
	 */
	public class VideoTag
	{
		public var data:ByteArray = null;
		public  const headLen:int = 11;
		
		//0x17 关键帧   0x27普通帧
		public var keyType:uint = 0x27;  
		
		private var _size:int = 0;
		
		public function VideoTag()
		{
		}
		
		
		//在当前ByteArray  中的起始位置
		public var pos:Number = 0;
		
		public function set size(value:int):void{
			_size = value;  
		}
		
		public function get size():int{
			return _size;
		}
		
		public function get tagLen():Number{
			//taghead len  +  data size  + pre tag size
			return headLen+_size+4;
		}
		
		
		public function print():void{
			if(data){
				var len:int = data.bytesAvailable;
				trace("size=",size);
				trace("head=",data[0].toString(16),data[1].toString(16),data[2].toString(16));
				trace("footer=",data[len-3].toString(16),data[len-2].toString(16),data[len-1].toString(16));
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