# Nexia map data specifications 

A nexia level consist on 3 major parts

`meta` which contains metadata about the level (Difficulties if is a pack, bpm, artist, mapper, title, etc.)

`lanes` is the heart of the file and contain definition of the notes and metadata about the lane itself

the fields for this are:

```json
"lanes": {
    // indexed by the control ID (internal name)
    // we expect the lanes to be indexed by the control name and not by a ID
    // also the indexed are limited to only 9 (1-8 and the main)
    "[control_name]": {
        "scrollSpeed": 1.5, // set the lane scrollspeed for the notes
        "notes": [], // the note data itself
    }
}
```

`events` which are the animations, effects and other stuff that may happen during the gameplay, like:

`spawnSprite`, `setShader`, `tween` etc..