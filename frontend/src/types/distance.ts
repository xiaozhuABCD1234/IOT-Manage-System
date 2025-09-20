export interface TypedID {
  kind: "mark" | "tag" | "type";
  mark_id?: string; // len=36, max=36
  tag_id?: number; // min=1
  type_id?: number; // min=1
}

export interface SetDistanceTypedReq {
  first: TypedID;
  second: TypedID;
  distance: number; // min=0
}

export interface SetDistanceMarkReq {
  mark1_id: string; // UUID
  mark2_id: string; // UUID
  distance: number; // min=0
}
