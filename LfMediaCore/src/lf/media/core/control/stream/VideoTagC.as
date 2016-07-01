package lf.media.core.control.stream
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import lf.media.core.model.flv.VideoTag;
	
	
	public class VideoTagC
	{
		public function VideoTagC()
		{
		}
		
		public function init(sourceB:URLStream,buffer:ByteArray):void{
			this._buffer = buffer;
			this._sourceB = sourceB;
		}
		
		
		/** return 0:是vudio tag   1:不是vudio tag   2：数据不够*/
		public function get  isVideo():int{
			
			if(_sourceB.bytesAvailable<_vt.headLen){
				return 2;
			}
			
			if(_buffer.bytesAvailable<_vt.headLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_vt.headLen-_buffer.bytesAvailable);
			}
			
			var flag:Boolean = _buffer.readByte() ==0x09;
			_buffer.position = 0;
			return flag? 0:1;
		}
		
		
		public function get tagData():VideoTag{
			_buffer.position = 0;
			var b:ByteArray = new ByteArray();
			_vt.size = (_buffer[1] << 16) | (_buffer[2] << 8) | (_buffer[3]);  
			
			if(_sourceB.bytesAvailable < _vt.tagLen){
				_vt.data = null;
				return _vt;
			}
			
			if(_buffer.bytesAvailable< _vt.tagLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_vt.tagLen-_buffer.bytesAvailable);
			}
			
			_buffer.position = 11;
			_vt.keyType = _buffer.readByte();
			_buffer.position = 0;
			
			_buffer.readBytes(b,0,_vt.tagLen);
			_vt.data = b;
			_buffer.position = 0;
			//print();
			return _vt;
		}
		
		
		public function print():void{
			var str:String = "s data=";
			for(var i:int=0; i<10; i++){
				str += _buffer[i].toString(16)+"|";
			}
			_buffer.position = 0;
			trace(str);
			
			var str1:String = "e data=";
			for(i=_buffer.length-10; i<_buffer.length; i++){
				str1 += _buffer[i].toString(16)+"|";
			}
			_buffer.position = 0;
			trace(str1);
			
		}
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		private var _vt:VideoTag = new VideoTag();
		
		
	}
}