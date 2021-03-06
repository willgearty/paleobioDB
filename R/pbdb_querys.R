# R Functions leveraging the use o the different API endpoints 
# available

#' .pbdb_query
#' 
#' Central function for sending all queries to the remote API
#'
#' @usage .pbdb_query(endpoint, query)
#'
#' @param endpoint Name of the endpoint, inside the API, to which the query must be sent. 
#' This endpoint must have been previously configured
#' @param query List of filter parameters for the api. The values provided to the parameters
#' may be a single string or a list of strings.
#' @return dataframe
#' @examples \dontrun{
#' .pbdb_query("occs/list", list(base_name="Canidae", show=c("coords", "phylo", "ident")))
#' }
#' 

.pbdb_query<-function(endpoint, query = list()){
  query <- lapply(query, .implode_to_string)
  uri <- .build_uri(endpoint, query = query)

  df <- .get_data_from_uri(uri)

  df
}


#' .implode_to_string
#'
#' Converts a list of strings in a single comma separated string
#' 
#' @param params list of strings
#' @return character
#' @examples \dontrun{
#' .implode_to_string(list("categoryA","categoryB","categoryC"))
#' }

.implode_to_string<-function(params){
  
  if(!(is.vector(params))){
    stop("Vector expected")
  }
  
  if(length(params) > 1){
    str <- params[[1]]
    for (p in params[2:length(params)]) {
      str <- paste(str, ",", p, sep = "")
    }
  } else {
    str <- params
  }
  
  return (str)
}


#' pbdb_occurrence 
#' 
#' Returns information about a single occurrence record from the Paleobiology 
#' Database.
#' 
#' Documentation for all the parameters is available at 
#' http://paleobiodb.org/data1.1/occs/single. In the parameter list above, we
#' describe the most common filters that paleontologists and ecologists might
#' use.
#' 
#' @usage pbdb_occurrence (id, ...)
#' @param id identifier of the occurrence. This parameter is required
#' @param ... arguments passed to the API. See all available arguments in
#'   \url{http://paleobiodb.org/data1.1/occs/single}. Eg:
#'   \itemize{
#'    \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'      default variables have short 3-letter names)
#'   }
#' @return a dataframe with a single occurrence 
#' 
#' @export 
#' 
#' @examples \dontrun{
#' pbdb_occurrence (id=1001)
#' pbdb_occurrence (id=1001, vocab="pbdb", show="coords")
#' }

pbdb_occurrence<-function(id, ...){
  l<-list(...)
  # todo: merge lists properly  
  .pbdb_query('occs/single', query = c(list(id = id), l))
}


#' pbdb_occurrences
#'
#' Returns information about species occurrence records stored in the
#' Paleobiology Database.
#'
#' Documentation for all the parameters is available 
#' at \url{http://paleobiodb.org/data1.1/occs/list}. We describe the most common
#' filters that paleontologists and ecologists might use in the parameter list above.
#' 
#' @param ... arguments passed to the API. See all available arguments in
#'   \url{http://paleobiodb.org/data1.1/occs/list}
#'   \itemize{
#'     \item \emph{limit}: sets limit to "all" to download all the occurrences. 
#'       By default the limit is 500. 
#'     \item \emph{taxon_name}: Return only records associated with the 
#'       specified taxonomic name(s). 
#'       You may specify multiple names, separated by commas.
#'     \item \emph{base_name}:  Return records associated with the specified 
#'       taxonomic name(s) and any of their children (e.g. base_name="Canis" will 
#        return "Canis", "Canis lupus", "Canis mosbachensis", etc.)
#'     \item \emph{lngmin}: numeric. The longitude boundaries will be normalized 
#'       to fall between -180 and 180. Note that if you specify 
#'       lngmin then you must also specify lngmax. 
#'       Returns only records whose geographic location falls 
#'       within the given bounding box (defined by lngmin, lngmax, 
#'       latmin, latmax).
#'       It generates two adjacent bounding boxes if the range crosses
#'       the antimeridian. 
#'     \item \emph{lngmax}: numeric. The longitude boundaries will be normalized 
#'       to fall between -180 and 180.
#'     \item \emph{latmin}: numeric. between -90 and 90. 
#'       Note that if you specify latmin then you must also specify latmax.
#'     \item \emph{latmax}: numeric. between -90 and 90.
#'     \item \emph{min_ma}: return only records whose temporal 
#'       locality is at least this old, specified in Ma.
#'     \item \emph{max_ma}: return only records whose temporal 
#'       locality is at most this old, specified in Ma.
#'     \item \emph{interval}: return only records whose temporal 
#'       locality falls within the named geologic time interval 
#'       (e.g. "Miocene").
#'     \item \emph{continent}: return only records whose geographic 
#'       location falls within the specified continent(s). 
#'     \item \emph{show}: to show extra variables (e.g. coords, phylo, ident)
#'   }
#' @return a dataframe with the species occurrences 
#' 
#' @export 
#' 
#' @examples \dontrun{
#' pbdb_occurrences (id=c(10, 11), show=c("coords", "phylo", "ident")) 
#' pbdb_occurrences (limit="all", vocab= "pbdb", 
#' taxon_name="Canis", show=c("coords", "phylo", "ident"))
#' pbdb_occurrences (limit="all", vocab= "pbdb", 
#' base_name="Canidae", show=c("coords", "phylo", "ident"))
#' }


pbdb_occurrences<-function(...){

  l<-list(...)
	.pbdb_query('occs/list', query = l)

}


#' pbdb_ref_occurrences
#' 
#' Returns information about the bibliographic references 
#' associated with fossil occurrences from the database.
#'
#' Go to \code{\link{pbdb_occurrences}} to see an explanation about the main 
#' filtering parameters. 
#'
#' @usage pbdb_ref_occurrences (...)
#'
#' @param ... arguments passed to the API. See all available arguments in
#'   \url{http://paleobiodb.org/data1.1/occs/refs}
#'   \itemize{
#'     \item \emph{author} select only references for which any of the authors 
#'       matches the specified name
#'     \item \emph{year} select only references published in the specified year
#'     \item \emph{pubtitle} select only references that involve the specified 
#'       publication
#'     \item \emph{order} specifies the order in which the results are returned. You can
#'       specify multiple values separated by commas, and each value may be appended
#'       with .asc or .desc. Accepted values are: author, year, pubtitle, created,
#'       modified, rank.
#'   }
#' @return a dataframe with the information about the references 
#' that match the query
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_ref_occurrences (vocab="pbdb", 
#' base_name="Canis", year=2000)
#'}


pbdb_ref_occurrences<-function(...){
  
  l<-list(...)
  .pbdb_query('occs/refs', query = l)
  
}


#' pbdb_collection 
#' 
#' Returns information about a single collection record from 
#' the Paleobiology Database.
#' 
#' Go to \code{\link{pbdb_occurrences}} to see an explanation about 
#' the main filtering parameters.
#' 
#' @usage pbdb_collection (id, ...)
#'  
#' @param id identifier of the collection. This parameter is required.
#' @param ... additional arguments passed to the API. See all available arguments in
#'   \url{http://paleobiodb.org/data1.1/colls/single}. Eg:
#'   \itemize{
#'     \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'       default variables have short 3-letter names)
#'     \item \emph{show}: show extra variables
#'     \item ...
#'   }
#'
#' @return a dataframe with a single occurrence 
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_collection (id=1003, vocab="pbdb", show="loc")
#' 
#'}


pbdb_collection<-function(id, ...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('colls/single', query = c(list(id = id), l))
}

#'pbdb_collections
#'
#'Returns information about multiple collections, selected 
#'according to the parameters you provide.
#'
#'@usage pbdb_collections (...)
#'
#'@param ... documentation for all the parameters is available 
#'in http://paleobiodb.org/data1.1/colls/list
#' go to \code{\link{pbdb_occurrences}} to see an explanation about 
#' the main filtering parameters 
#' 
#' @return a dataframe with the collections that match the query
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_collections (base_name="Cetacea", interval="Miocene")
#'}


pbdb_collections<-function(...){
  
  l<-list(...)
  .pbdb_query('colls/list', query = l)
  
}

#'pbdb_collections_geo
#'
#'This path returns information about geographic clusters 
#'of collections from the Paleobiology Database. 
#'These clusters are defined in order to facilitate the 
#'generation of maps at low resolutions. 
#'You can make a config request via 
#'http://paleobiodb.org/data1.1/config
#'in order to get a list of the available summary levels.
#'
#'@usage pbdb_collections_geo (...)
#'
#'@param ... documentation for all the parameters is 
#'available in http://paleobiodb.org/data1.1/colls/summary
#' go to \code{\link{pbdb_occurrences}} to see an explanation about 
#' the main filtering parameters 
#' 
#' @return a dataframe with the collections that match the query
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_collections_geo (vocab="pbdb", lngmin=0.0, 
#' lngmax=15.0, latmin=0.0, latmax=15.0, level=2)
#'}


pbdb_collections_geo<-function(...){
  
  l<-list(...)
  .pbdb_query('colls/summary', query = l)
  
}

#'pbdb_taxon
#' 
#'Returns information about a single taxonomic name, 
#'identified either by name or by identifier.
#'
#'@usage pbdb_taxon (...)
#'@param ... arguments passed to the API. See
#'  documentation for accepted parameters in
#'  \url{http://paleobiodb.org/data1.1/taxa/single}. Eg:
#'  \itemize{
#'    \item \emph{name}: returns information about the most fundamental 
#'      taxonomic name matching this string. 
#'      The \% and _ characters may be used as wildcards.
#'    \item ...
#'  }
#' @return a dataframe with information from a single taxon
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_taxon (name="Canis", vocab="pbdb", 
#' show=c("attr", "app", "size"))
#' 
#'}


pbdb_taxon<-function(...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('taxa/single', query = l)
}


#' pbdb_taxa
#' 
#'Returns information about multiple taxonomic names.  This function can be
#'used to query for all of the children or parents of a given taxon, among
#'other operations.
#'
#'@usage pbdb_taxa (...)
#'@param ... arguments passed to the API. See all available arguments in
#'  \url{http://paleobiodb.org/data1.1/taxa/list}
#'  \itemize{
#'    \item \emph{name}: returns information about the most fundamental 
#'      taxonomic name matching this string. 
#'      The \% and _ characters may be used as wildcards.
#'    \item \emph{id}: return information about the taxonomic name 
#'      corresponding to this identifier. You may not specify both 
#'      name and id in the same query.
#'    \item \emph{exact}: if this parameter is specified, then the taxon exactly 
#'      matching the specified name or identifier is selected, 
#'      rather than the senior synonym which is the default.
#'    \item \emph{show}: to show extra variables: \emph{attr} 
#'      the attribution of this taxon (author and year); 
#'      \emph{app} the age of first and last appearance of this taxon 
#'      from the occurrences recorded in this database; 
#'      \emph{size} the number of subtaxa appearing in this database; 
#'      \emph{nav} additional information for the PBDB Navigator taxon browser
#'    \item \emph{rel}: set rel="synonyms" to select all synonyms of 
#'      the base taxon or taxa; rel="children" to select the 
#'      taxa immediately contained within the base taxon or taxa; 
#'      rel="common_ancestor" to select the most specific taxon 
#'      that contains all of the base taxa.
#'    \item \emph{extant}: TRUE/FALSE to select extant/extinct taxa.
#'  }

#' @return a dataframe with information from a list of taxa
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_taxa (name="Canidae", vocab="pbdb", 
#' show=c("attr", "app", "size", "nav"))
#' pbdb_taxa (id =c(10, 11), vocab="pbdb", 
#' show=c("attr", "app", "size", "nav"))
#' pbdb_taxa (id =c(10, 11), vocab="pbdb", 
#' show=c("attr", "app", "size", "nav"), rel="common_ancestor")
#'}


pbdb_taxa<-function(...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('taxa/list', query = l)
}


#' pbdb_taxa_auto
#' 
#' Returns a list of names matching the given prefix or partial name. 
#' 
#' @usage pbdb_taxa_auto (...)
#' @param ... arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/taxa/auto_doc.html}. Eg:
#'   \itemize{
#'     \item \emph{name}: a partial name or prefix. 
#'       It must have at least 3 significant characters,
#'       and may include both a genus
#'       (possibly abbreviated) and a species.
#'     \item \emph{limit}: set the limit to the number of matches
#'     \item ...
#'   }

#' @return a dataframe with information about the matches 
#' (taxon rank and number of occurrences in the database)
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_taxa_auto (name="Cani", limit=10) 
#'}


pbdb_taxa_auto<-function(...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('taxa/auto', query = l)
}



#'pbdb_interval
#' 
#'Returns information about a single interval, selected by identifier.
#'
#'@usage pbdb_interval (id, ...) 
#'
#'@param id identifier of the temporal interval. This parameter is required.
#'@param ... additional arguments passed to the API. See
#'  documentation for accepted parameters in
#'  \url{http://paleobiodb.org/data1.1/intervals/single}. Eg:
#'  \itemize{
#'    \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'      default variables have short 3-letter names)
#'  }

#' @return a dataframe with information from a single 
#' temporal interval
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_interval (id=1, vocab="pbdb")
#'}

pbdb_interval<-function(id, ...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('intervals/single', query = c(list(id = id), l))
}



#'pbdb_intervals
#' 
#'Returns information about multiple intervals, 
#'selected according to the parameters you provide.
#'
#'@usage pbdb_intervals (...)
#'
#'@param ... arguments passed to the API. See
#'  documentation for accepted parameters in
#'  \url{http://paleobiodb.org/data1.1/intervals/list}. Eg:
#'  \itemize{
#'    \item \emph{min_ma}: return only intervals that are at least this old
#'    \item \emph{max_ma}: return only intervals that are at most this old
#'    \item \emph{order}: return the intervals in order starting as specified. 
#'      Possible values include older, younger. Defaults to younger
#'    \item \emph{vocab}: set vocab="pbdb" to show 
#'      the complete name of the variables (by
#'      default variables have short 3-letter names)
#'    \item ...
#'  }

#'@return a dataframe with information from several temporal intervals
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_intervals (min_ma= 0, max_ma=2, vocab="pbdb") 
#'}
 

pbdb_intervals<-function(...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('intervals/list', query = l)
}


#' pbdb_scale
#' 
#' Returns information about a single time scale, selected by 
#' identifier.
#'
#' @usage pbdb_scale (id, ...)
#' @param id identifier of the temporal interval. This parameter is required.
#' @param ... additional arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/scales/single}. Eg:
#'   \itemize{
#'     \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'       default variables have short 3-letter names)
#'     \item ...
#'   }
#' @return a dataframe with information from a single scale
#' 
#' @export 
#' @examples \dontrun{
#'   pbdb_scale (id=1, vocab="pbdb")
#' }
 

pbdb_scale<-function(id, ...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('scales/single', query = c(list(id = id), l))
}

#' pbdb_scales
#' 
#' Returns information about multiple time scales.
#'
#' @param ... arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/scales/list}. Eg:
#'   \itemize{
#'     \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'       default variables have short 3-letter names)
#'     \item ...
#'   }

#' @return a dataframe with information from the selected scales
#'  
#' @export 
#' @examples \dontrun{
#' ## Get a dataframe with all the scales available in PBDB 
#' ## by setting no ids
#' pbdb_scales ()
#' }
#' 

pbdb_scales<-function(...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('scales/list', query = l)
}



#'pbdb_strata
#' 
#' Returns information about geological strata, 
#' selected by name, rank, and/or geographic location.
#' 
#'@usage pbdb_strata (...)
#' @param ... arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/strata/list}. Eg:
#'   \itemize{
#'     \item \emph{name}: a full or partial name. You can
#'       use \% and _ as wildcards, but the
#'       query will be very slow if you put a wildcard at the beginning
#'     \item \emph{rank}: returns only strata of the specified 
#'       rank: formation, group or member.
#'     \item \emph{lngmin}: numeric. The longitude boundaries will be normalized to fall
#'       between -180 and 180. Note that if you specify lngmin then you must also
#'       specify lngmax. Returns only records whose geographic location falls within
#'       the given bounding box (defined by lngmin, lngmax, latmin, latmax). It
#'       generate two adjacent bounding boxes if the range crosses the antimeridian. 
#'     \item \emph{lngmax}: numeric. The longitude boundaries will be normalized to fall
#'       between -180 and 180.
#'     \item \emph{latmin}: numeric. between -90 and 90. Note that if you specify latmin
#'       then you must also specify latmax.
#'     \item \emph{latmax}: numeric. between -90 and 90.
#'     \item \emph{loc}: Return only strata associated with some occurrence whose
#'       geographic location falls within the specified geometry, specified in WKT
#'       format.
#'     \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'       default variables have short 3-letter names)
#'     \item ...
#'   }
#' @return a dataframe with information from the selected strata
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_strata (lngmin=0, lngmax=15, latmin=0, latmax=15, rank="formation", vocab="pbdb") 
#'}


pbdb_strata<-function(...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('strata/list', query = l)
}



#' pbdb_strata_auto
#' 
#' Returns a list of strata matching the given prefix or partial name. 
#' This can be used to implement auto-completion for strata names, 
#' and can be limited by geographic location if desired.
#'
#' @usage pbdb_strata_auto (...)
#'
#' @param ... arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/strata/auto}. Eg:
#'   \itemize{
#'     \item \emph{name}: a full or partial name. You can
#'       use \% and _ as wildcards, but the
#'       query will be very slow if you put a wildcard at the beginning
#'     \item \emph{rank}: returns only strata of the specified 
#'       rank: formation, group or member.
#'     \item \emph{lngmin}: numeric. The longitude boundaries will be normalized to fall
#'       between -180 and 180. Note that if you specify lngmin then you must also
#'       specify lngmax. Returns only records whose geographic location falls within
#'       the given bounding box (defined by lngmin, lngmax, latmin, latmax). It
#'       generate two adjacent bounding boxes if the range crosses the antimeridian. 
#'     \item \emph{lngmax}: numeric. The longitude boundaries will be normalized to fall
#'       between -180 and 180.
#'     \item \emph{latmin}: numeric. between -90 and 90. Note that if you specify latmin
#'       then you must also specify latmax.
#'     \item \emph{latmax}: numeric. between -90 and 90.
#'     \item \emph{loc}: Return only strata associated with some occurrence whose
#'       geographic location falls within the specified geometry, specified in WKT
#'       format.
#'     \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'       default variables have short 3-letter names)
#'     \item ...
#'   }
#' @return a dataframe with information from the strata that matches our letters.
#' 
#' @export 
#' @examples \dontrun{
#' pbdb_strata_auto (name= "Pin", vocab="pbdb") 
#'}


pbdb_strata_auto<-function(...){
  l<-list(...)
  
  # todo: merge lists properly  
  .pbdb_query('strata/auto', query = l)
}


#' pbdb_reference
#' 
#' Returns information about a single reference, selected by identifier.
#' Go to \code{\link{pbdb_occurrences}} to see an explanation about the main filtering parameters 
#' 
#' @usage pbdb_reference (id, ...)
#' 
#' @param id identifier of the reference. This parameter is required.
#' @param ... arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/refs/single}. Eg:
#'   \itemize{
#'     \item \emph{vocab}: set vocab="pbdb" to show the complete name of the variables (by
#'       default variables have short 3-letter names)
#'     \item ...
#'   }
#' @return a dataframe with a single reference 
#' @export 
#' @examples \dontrun{
#' pbdb_collection (id=1003, vocab="pbdb", show="loc")
#' }

 
pbdb_reference<-function(id, ...){
  
  l<-list(...)
  .pbdb_query('refs/single', query = c(list(id = id), l))
  
}



#' pbdb_references
#' 
#' Returns information about multiple references, selected according to the parameters you provide.
#' 
#' @usage pbdb_references (...)
#' 
#' @param ... arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/refs/list}. Eg:
#'   \itemize{
#'     \item \emph{author} select only references for which any of the authors 
#'       matches the specified name
#'     \item \emph{year} select only references published in the specified year
#'     \item \emph{pubtitle} select only references that involve the specified 
#'       publication
#'     \item \emph{order} specifies the order in which the results are returned. You can
#'       specify multiple values separated by commas, and each value may be appended
#'       with .asc or .desc. Accepted values are: author, year, pubtitle, created,
#'       modified, rank.
#'     \item ...
#'   }
#' @return a dataframe with the information about the references that match the query
#'  
#' @export 
#' @examples \dontrun{
#'   pbdb_references (author= "Polly")
#' }


pbdb_references<-function(...){
  
  l<-list(...)
  .pbdb_query('refs/list', query = l)
  
}


#' pbdb_ref_collections
#' 
#' Returns information about the references from which the selected collection data were entered.
#' 
#' @usage pbdb_ref_collections (...)
#' @param ... arguments passed to the API. See
#'   documentation for accepted parameters in
#'   \url{http://paleobiodb.org/data1.1/colls/refs}. Eg:
#'   \itemize{
#'     \item \emph{id} comma-separated list of collection identifiers
#'     \item \emph{author} select only references for which any of the authors 
#'       matches the specified name
#'     \item \emph{year} select only references published in the specified year
#'     \item \emph{pubtitle} select only references that involve the specified 
#'       publication
#'     \item \emph{order} specifies the order in which the results are returned. You can
#'       specify multiple values separated by commas, and each value may be appended
#'       with .asc or .desc. Accepted values are: author, year, pubtitle, created,
#'       modified, rank.
#'     \item ...
#'   }
#' @return a dataframe with the information about the references that match the query
#' 
#' @export 
#' @examples \dontrun{
#'   pbdb_ref_collections (id=1)
#'}


pbdb_ref_collections <-function(...){
  
  l<-list(...)
  .pbdb_query('colls/refs', query = l)
  
}


#' pbdb_ref_taxa
#' 
#' This URL path returns information about the source references associated
#' with taxa in the Paleobiology Database. You can use the same parameters 
#' that are available with pbdb_taxa, but Reference records are returned 
#' instead of Taxon records. One record is returned per reference, 
#' even if it is associated with multiple taxa.
#' 
#' @usage pbdb_ref_taxa (...)
#' @param ... arguments passed to the API. See all available arguments in
#'   \url{http://paleobiodb.org/data1.1/taxa/refs}
#'   \itemize{
#'     \item \emph{name}: returns information about the most fundamental 
#'       taxonomic name matching this string. 
#'       The \% and _ characters may be used as wildcards.
#'     \item \emph{id}: returns information about the taxonomic name 
#'       corresponding to this identifier. You may not specify both 
#'       name and id in the same query.
#'     \item \emph{exact}: if this parameter is specified, then the taxon exactly 
#'       matching the specified name or identifier is selected, 
#'       rather than the senior synonym which is the default.
#'     \item \emph{show}: show extra variables
#'     \item \emph{rel}: set rel="synonyms" to select all synonyms of 
#'       the base taxon or taxa; rel="children" to select the 
#'       taxa immediately contained within the base taxon or taxa; 
#'       rel="common_ancestor" to select the most specific taxon 
#'       that contains all of the base taxa.
#'     \item \emph{extant}: TRUE/FALSE to select extant/extinct taxa.
#'   }
#' @return a dataframe with references from a list of taxa
#'  
#' @export 
#' @examples \dontrun{
#'   pbdb_ref_taxa (name="Canidae", vocab="pbdb", show=c("attr", "app", "size", "nav")) 
#' }


pbdb_ref_taxa <-function(...){
  
  l<-list(...)
  .pbdb_query('taxa/refs', query = l)
  
}
